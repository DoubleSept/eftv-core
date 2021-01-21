extends ARVROrigin


var left : EFTV_Controller
var right : EFTV_Controller

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
