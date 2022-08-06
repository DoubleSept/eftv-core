extends Node

enum MOVEMENT_WHEN { ALWAYS, ON_AIR, ON_FLOOR }

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

# Move And Rotation variable
var mnr_rotation_limit = 0.40

# and movement
export var drag_factor = 0.1

export (SaveSystem.MovementTypeEnum) var move_type = SaveSystem.MovementTypeEnum.MOVE_AND_HYBRID
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

	# We check witch controller is currently in use by checking the one with the more distance from the center
	var all_turning = true
	var left_right = 0
	var forwards_backwards = 0
	var max_distance = 0
	var current_controller = null
	for controller in controllers_nodes:
		if controller.get_is_active():
			# If jump we do not move
			if controller.is_button_pressed(jump_button_id) && canJump && tail.is_colliding():
				player_node.jump()
				current_controller = null
				break

			var tmp_left_right = controller.get_joystick_axis(0)
			var tmp_forwards_backwards = controller.get_joystick_axis(1)
			var tmp_distance = abs(tmp_left_right) + abs(tmp_forwards_backwards)
			if  tmp_distance > max_distance:
				left_right = tmp_left_right
				forwards_backwards = tmp_forwards_backwards
				max_distance = tmp_distance
				current_controller = controller

			if abs(tmp_left_right) < mnr_rotation_limit:
				all_turning = false

	if current_controller == null:
		# No need to move
		return

	if(left_right > 0 && forwards_backwards > 0):
		print("Value LR: %f | Value FB: %f" % [left_right, forwards_backwards])

	# Check if we move or turn
	var isTurning = false
	match move_type:
		SaveSystem.MovementTypeEnum.MOVE_AND_STRAFE:
			pass
		SaveSystem.MovementTypeEnum.MOVE_AND_ROTATE:
			if abs(left_right) > mnr_rotation_limit:
				isTurning = true
			else:
				turn_step = 0.0
		SaveSystem.MovementTypeEnum.MOVE_AND_HYBRID:
			if all_turning :
				isTurning = true
			else:
				turn_step = 0.0

	var can_move =  (
			move_when == MOVEMENT_WHEN.ALWAYS
			or
			(move_when == MOVEMENT_WHEN.ON_FLOOR && tail.is_colliding())
			or
			(move_when == MOVEMENT_WHEN.ON_AIR && !tail.is_colliding())
	)

	# Check not rotation
	if isTurning:
		rotateBuffer(delta, left_right)
	elif(can_move):
		movePlayer(delta, forwards_backwards, left_right)

func rotateBuffer(delta, left_right):
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

func movePlayer(delta, forwards_backwards, left_right):
	var camera_transform = camera_node.global_transform
	var dir_forward = camera_transform.basis.z if abs(forwards_backwards) > 0.1 else Vector3(0,0,0)
	dir_forward.y = 0.0
	# VR Capsule will strafe left and right
	var dir_right = camera_transform.basis.x if abs(left_right) > 0.1 else Vector3(0,0,0)
	dir_right.y = 0.0
	velocity = (dir_forward * -forwards_backwards + dir_right * left_right).normalized() * delta * player_node.movement_speed * ARVRServer.world_scale
	player_node.translate(velocity)
