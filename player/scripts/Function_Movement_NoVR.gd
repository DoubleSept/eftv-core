extends Node

# Is this active?
export var enabled = true setget set_enabled, get_enabled

onready var player_node : EftvPlayer = get_parent()
var player_camera : Camera setget set_camera

const CONTROLLER_DEADZONE = 0.25


func _ready():
	pass

func set_enabled(new_value):
	enabled = new_value
	if enabled:
		# make sure our physics process is on
		set_physics_process(true)
	else:
		# we turn this off in physics process just in case we want to do some cleanup
		pass

func get_enabled():
	return enabled

func _physics_process(delta):
	if !enabled:
		set_physics_process(false)
		set_process_input(false)
		return
		
	set_process_input(true)
		
	if !player_camera:
		return
		
	player_node.translate(get_joystick_movement(delta))
	
	
func _input(event):
	if event.is_action_pressed("jump_novr"):
		if player_node.is_on_floor():
			player_node.jump()
	
func get_joystick_movement(delta: float) -> Vector3:
	# Directional movement
	# --------------------
	var trackpad_vector = Vector2(
		-Input.get_joy_axis(0,1), 
		Input.get_joy_axis(0,0))
	var joystick_vector = Vector2(
		-Input.get_joy_axis(0,5), 
		Input.get_joy_axis(0,4))

	if trackpad_vector.length() < CONTROLLER_DEADZONE:
		trackpad_vector = Vector2(0, 0)
	else:
		trackpad_vector = trackpad_vector.normalized() * ((trackpad_vector.length() - CONTROLLER_DEADZONE) / (1 - CONTROLLER_DEADZONE))

	if joystick_vector.length() < CONTROLLER_DEADZONE:
		joystick_vector = Vector2(0, 0)
	else:
		joystick_vector = joystick_vector.normalized() * ((joystick_vector.length() - CONTROLLER_DEADZONE) / (1 - CONTROLLER_DEADZONE))

	var forward_direction = -1 * player_camera.global_transform.basis.z.normalized()

	var right_direction = player_camera.global_transform.basis.x.normalized()

	var movement_vector = (trackpad_vector + joystick_vector).normalized()

	var movement_forward = forward_direction * movement_vector.x * delta * player_node.movement_speed
	var movement_right = right_direction * movement_vector.y * delta * player_node.movement_speed

	movement_forward.y = 0
	movement_right.y = 0

	if movement_right.length() > 0 or movement_forward.length() > 0:
		var movement = movement_right + movement_forward
		return movement
	else:
		return Vector3(0,0,0)
		
func set_camera(camera):
	player_camera = camera
