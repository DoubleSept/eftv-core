extends ARVRController
class_name EFTV_ControllerOLD

onready var grab_pos_node = $Grab_Pos
onready var player_node = get_parent().get_parent()
var player_camera : Camera setget set_camera

var controller_velocity = Vector3(0, 0, 0)
var prior_controller_position = Vector3(0, 0, 0)
var prior_controller_velocities = []

var held_object = null

var grab_mode = "AREA"

const CONTROLLER_DEADZONE = 0.25
const MOVEMENT_SPEED = 8.5

var directional_movement = false

func _ready():
	grab_mode = "AREA"
	get_node("Sleep_Area").connect("body_entered", self, "sleep_area_entered")
	get_node("Sleep_Area").connect("body_exited", self, "sleep_area_exited")

	connect("button_pressed", self, "button_pressed")
	connect("button_release", self, "button_released")


func _physics_process(delta):
	# Controller velocity
	# --------------------
	if get_is_active():
		controller_velocity = Vector3(0, 0, 0)

		if prior_controller_velocities.size() > 0:
			for vel in prior_controller_velocities:
				controller_velocity += vel

			# Get the average velocity, instead of just adding them together.
			controller_velocity = controller_velocity / prior_controller_velocities.size()

		prior_controller_velocities.append((global_transform.origin - prior_controller_position) / delta)

		controller_velocity += (global_transform.origin - prior_controller_position) / delta
		prior_controller_position = global_transform.origin

		if prior_controller_velocities.size() > 30:
			prior_controller_velocities.remove(0)

	# --------------------

	if held_object:
		var held_scale = held_object.scale
		held_object.global_transform = grab_pos_node.global_transform
		held_object.scale = held_scale

func get_movement(delta: float) -> Vector3:
	# Directional movement
	# --------------------
	# NOTE: you may need to change this depending on which VR controllers
	# you are using and which OS you are on.
	var trackpad_vector = Vector2(-get_joystick_axis(1), get_joystick_axis(0))
	var joystick_vector = Vector2(-get_joystick_axis(5), get_joystick_axis(4))

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
		directional_movement = true
		return movement
	else:
		directional_movement = false
		return Vector3(0,0,0)
	# --------------------


func button_pressed(button_index):
	# If the trigger is pressed...
	if button_index == 15:
		if held_object:
			if held_object.has_method("interact"):
				held_object.interact()

	# If any button is pressed...
	if player_node.has_method("is_on_floor") and player_node.is_on_floor() and (button_index == 15):
		player_node.vel.y = player_node.JUMP_SPEED

func button_released(button_index):
	pass

func sleep_area_entered(body):
	if "can_sleep" in body:
		body.can_sleep = false
		body.sleeping = false

func sleep_area_exited(body):
	if "can_sleep" in body:
		body.can_sleep = true
		
func set_camera(camera):
	player_camera = camera
