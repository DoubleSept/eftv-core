extends ARVROrigin

class_name PlayerOrigin

var left : EFTV_Controller
var right : EFTV_Controller

var player_node = get_parent()
var player_triangle
var player_camera : Camera setget set_camera

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
	var movementLeft : Vector3 = left.get_movement(delta)
	var movementRight : Vector3 = right.get_movement(delta)
	
	if movementLeft.length() > movementRight.length():
		player_node.translate(movementLeft)
	else:
		player_node.translate(movementRight)
		
func set_camera(camera):
	prints("Switching camera to", camera)
	player_camera = camera
	left.player_camera = camera
	right.player_camera = camera