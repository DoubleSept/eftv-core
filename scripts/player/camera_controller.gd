extends Camera

signal has_moved

const CAMERA_SPEED = 0.05
const MIN_X = -1.0
const MAX_X = 1.0
const DEATH_STICK = 0.2

var currentCameraSpeed : float= 0.0
var currentPlayerTurningSpeed : float= 0.0
onready var player_node = get_parent().get_parent()

func _ready():
	set_process_input(true)
	set_process(true)

func _input(event):
	if event is InputEventJoypadMotion and event.get_axis() == JOY_AXIS_3:
		currentCameraSpeed = event.get_axis_value()
	if event is InputEventJoypadMotion and event.get_axis() == JOY_AXIS_2:
		currentPlayerTurningSpeed = event.get_axis_value()
	if event is InputEventJoypadButton and event.get_button_index() == 0:
		# JUMP
		if player_node.is_on_floor():
			 player_node.vel.y = player_node.JUMP_SPEED

func _process(_delta):
	if currentCameraSpeed < -DEATH_STICK or currentCameraSpeed > DEATH_STICK:
		rotation.x -= currentCameraSpeed*CAMERA_SPEED
	if rotation.x > MAX_X:
		rotation.x = MAX_X
	elif rotation.x < MIN_X:
		rotation.x = MIN_X
		
	if currentPlayerTurningSpeed < -DEATH_STICK or currentPlayerTurningSpeed > DEATH_STICK:
		rotation.y -= currentPlayerTurningSpeed*CAMERA_SPEED
