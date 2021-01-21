extends ARVROrigin

class_name PlayerOrigin

var left : EFTV_Controller
var right : EFTV_Controller

var player_node = get_parent()
var player_triangle
var player_camera : Camera setget set_camera

const CONTROLLER_DEADZONE = 0.25
const MOVEMENT_SPEED = 8.5

func _ready():
	# load controllers
	left = $Left_Controller
	right = $Right_Controller
	
	if not left.get_is_active():
		left.visible = false
		
	if not right.get_is_active():
		right.visible = false
		
	# load player node
	player_node = get_parent()
	# triangle
	player_triangle = player_node.get_node("triangle")

func _physics_process(delta):
	if(player_triangle):
		player_triangle.rotation = Vector3(player_triangle.rotation.x, 
			player_camera.rotation.y, 
			0)
			
	# Call children for movement
	if player_node.has_method("getUsingVR") and not player_node.getUsingVR():
		player_node.translate(get_joystick_movement(delta))
	
	var movementLeft : Vector3 = left.get_movement(delta)
	var movementRight : Vector3 = right.get_movement(delta)
	
	if movementLeft.length() > movementRight.length():
		player_node.translate(movementLeft)
	else:
		player_node.translate(movementRight)
		
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

	var forward_direction = player_camera.global_transform.basis.z.normalized()
	
	if player_node.has_method("getUsingVR") and not player_node.getUsingVR():
		forward_direction = -1 * forward_direction

	var right_direction = player_camera.global_transform.basis.x.normalized()

	var movement_vector = (trackpad_vector + joystick_vector).normalized()

	var movement_forward = forward_direction * movement_vector.x * delta * MOVEMENT_SPEED
	var movement_right = right_direction * movement_vector.y * delta * MOVEMENT_SPEED

	movement_forward.y = 0
	movement_right.y = 0

	if movement_right.length() > 0 or movement_forward.length() > 0:
		var movement = movement_right + movement_forward
		return movement
	else:
		return Vector3(0,0,0)
		
func set_camera(camera):
	prints("\tSwitching camera to", camera)
	player_camera = camera
	left.player_camera = camera
	right.player_camera = camera
