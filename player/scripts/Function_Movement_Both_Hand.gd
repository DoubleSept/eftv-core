extends Node

enum MOVEMENT_WHEN { ALWAYS, ON_AIR, ON_FLOOR }
enum MOVEMENT_TYPE { MOVE_AND_ROTATE, MOVE_AND_STRAFE }

# Is this active?
export var enabled = true setget set_enabled, get_enabled

# We don't know the name of the camera node... 
export (NodePath) var camera = null
export (NodePath) var left_controller = null
export (NodePath) var right_controller = null

# size of our player
export var player_radius = 0.4 setget set_player_radius, get_player_radius

# to combat motion sickness we'll 'step' our left/right turning
export var smooth_rotation = false
export var smooth_turn_speed = 2.0
export var step_turn_delay = 0.2
export var step_turn_angle = 20.0

# and movement
export var drag_factor = 0.1

export (MOVEMENT_TYPE) var move_type = MOVEMENT_TYPE.MOVE_AND_STRAFE
export (MOVEMENT_WHEN) var move_when = MOVEMENT_WHEN.ALWAYS

# Jump
export var canJump = true
export (int) var jump_button_id = JOY_VR_TRIGGER

var player_node : EftvPlayer = null
var camera_node : Camera = null
var origin_node : ARVROrigin = null

var controllers_nodes = []

var turn_step = 0.0
var velocity = Vector3(0.0, 0.0, 0.0)
var gravity = -20.0
onready var collision_shape: CollisionShape = get_node("../CollisionShape")
onready var tail : RayCast = get_node("../Tail")

func set_enabled(new_value):
	enabled = new_value
	if tail:
		tail.enabled = enabled
	if enabled:
		# make sure our physics process is on
		set_physics_process(true)
	else:
		# we turn this off in physics process just in case we want to do some cleanup
		pass

func get_enabled():
	return enabled

func get_player_radius():
	return player_radius

func set_player_radius(p_radius):
	player_radius = p_radius

func _ready():
	# origin node should always be the parent of our parent
	player_node = get_parent()
	camera_node = get_node(camera)
	origin_node = player_node.get_node("ARVROrigin")
	controllers_nodes = [get_node(left_controller), get_node(right_controller)]
	
	# Our properties are set before our children are constructed so just re-issue
	set_player_radius(player_radius)

func _physics_process(delta):
	if !camera_node:
		return
	
	if !enabled:
		set_physics_process(false)
		return
	
	# Adjust the height of our player according to our camera position
	var player_height = camera_node.transform.origin.y + player_radius
	if player_height < player_radius:
		# not smaller than this
		player_height = player_radius
	
	collision_shape.shape.radius = player_radius
	collision_shape.shape.height = player_height - (player_radius * 2.0)
	collision_shape.transform.origin.y = (player_height / 2.0)
	
	# We should be the child or the controller on which the function is implemented
	for controller in controllers_nodes:
		if controller.get_is_active():
			var left_right = controller.get_joystick_axis(0)
			var forwards_backwards = controller.get_joystick_axis(1)
			if(left_right > 0 && forwards_backwards > 0):
				print("Value LR: %f | Value FB: %f" % [left_right, forwards_backwards])
			
			# if jump_button_id is pressed and we can jump and we are on floor
			if controller.is_button_pressed(jump_button_id) && canJump && tail.is_colliding():
				player_node.jump()
			
			################################################################
			# first process turning, no problems there :)
			else:
				if move_type == MOVEMENT_TYPE.MOVE_AND_STRAFE:
					pass
				elif(move_type == MOVEMENT_TYPE.MOVE_AND_ROTATE && abs(left_right) > 0.35):
					if smooth_rotation:
						# we rotate around our Camera, but we adjust our origin, so we need a little bit of trickery
						var t1 = Transform()
						var t2 = Transform()
						var rot = Transform()
						
						t1.origin = -camera_node.transform.origin
						t2.origin = camera_node.transform.origin
						rot = rot.rotated(Vector3(0.0, -1.0, 0.0), smooth_turn_speed * delta * left_right)
						origin_node.transform *= t2 * rot * t1
						
						# reset turn step, doesn't apply
						turn_step = 0.0
					else:
						if left_right > 0.0:
							if turn_step < 0.0:
								# reset step
								turn_step = 0
							
							turn_step += left_right * delta
						else:
							if turn_step > 0.0:
								# reset step
								turn_step = 0
							
							turn_step += left_right * delta
						
						if abs(turn_step) > step_turn_delay:
							# we rotate around our Camera, but we adjust our origin, so we need a little bit of trickery
							var t1 = Transform()
							var t2 = Transform()
							var rot = Transform()
							
							t1.origin = -camera_node.transform.origin
							t2.origin = camera_node.transform.origin
							
							# Rotating
							while abs(turn_step) > step_turn_delay:
								if (turn_step > 0.0):
									rot = rot.rotated(Vector3(0.0, -1.0, 0.0), step_turn_angle * PI / 180.0)
									turn_step -= step_turn_delay
								else:
									rot = rot.rotated(Vector3(0.0, 1.0, 0.0), step_turn_angle * PI / 180.0)
									turn_step += step_turn_delay
							
							origin_node.transform *= t2 * rot * t1
				else:
					# reset turn step, no longer turning
					turn_step = 0.0
			
				################################################################
				# now we do our movement
				# We start with placing our KinematicBody in the right place
				# by centering it on the camera but placing it on the ground
				var curr_transform = player_node.global_transform
				var camera_transform = camera_node.global_transform
				#curr_transform.origin = camera_transform.origin
				#curr_transform.origin.y = origin_node.global_transform.origin.y
				
				player_node.global_transform = curr_transform
				
				# we'll handle gravity separately
				velocity.y = 0.0
				
				# Apply our drag
				velocity *= (1.0 - drag_factor)
				
				var can_move = (
						move_when == MOVEMENT_WHEN.ALWAYS
						or
						(move_when == MOVEMENT_WHEN.ON_FLOOR && tail.is_colliding())
						or
						(move_when == MOVEMENT_WHEN.ON_AIR && !tail.is_colliding())
					)
				if can_move:
					if move_type == MOVEMENT_TYPE.MOVE_AND_ROTATE:
						if abs(forwards_backwards) > 0.1 && not abs(left_right) > 0.35:
							var dir = camera_transform.basis.z
							dir.y = 0.0					
							velocity = dir.normalized() * -forwards_backwards * delta * player_node.movement_speed * ARVRServer.world_scale
					elif move_type == MOVEMENT_TYPE.MOVE_AND_STRAFE:
						if abs(forwards_backwards) > 0.1 ||  abs(left_right) > 0.1:
							var dir_forward = camera_transform.basis.z
							dir_forward.y = 0.0				
							# VR Capsule will strafe left and right
							var dir_right = camera_transform.basis.x;
							dir_right.y = 0.0				
							velocity = (dir_forward * -forwards_backwards + dir_right * left_right).normalized() * delta * player_node.movement_speed * ARVRServer.world_scale
							
				# apply move and slide to our kinematic body
				print("Value Velocity: %s" % [velocity])
				player_node.translate(velocity)
