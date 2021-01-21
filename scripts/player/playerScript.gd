extends KinematicBody

signal player_fall

# Member variables
var g = -39.8
var vel = Vector3()
const MAX_SPEED = 5000

const JUMP_SPEED = 20

const ACCEL= 3
const DEACCEL= 4
const DEATH_STICK=0.2

const CAMERA_SPEED = 0.1
onready var cameraVR = $ARVROrigin/Player_Camera
onready var cameraNOVR : Camera = $ARVROrigin/NoVR_Camera
var currentCameraSpeed = 0.0
var inputDir = Vector3() # Where does the player is walking (relative)
var using_vr : bool = true setget setUsingVR, getUsingVR

func _ready():
	set_physics_process(true)
	$ARVROrigin.player_camera = (cameraNOVR if not getUsingVR() else cameraVR)
	
	pass

func _physics_process(delta):
	var dir = Vector3() # Where does the player intend to walk to

	dir.y = 0
	dir = dir.normalized()

	vel.y += delta*g

	var hvel = vel
	hvel.y = 0

	var target = dir * MAX_SPEED * delta
	var accel
	if (dir.dot(hvel) > 0):
		accel = ACCEL
	else:
		accel = DEACCEL

	hvel = hvel.linear_interpolate(target, accel*delta)

	vel.x = hvel.x
	vel.z = hvel.z

	vel = move_and_slide(vel,Vector3(0,1,0))

	# Reset when falling
	if(get_translation().y < -25):
		print("Player is falling")
		emit_signal("player_fall")
		#get_tree().reload_current_scene()

func setUsingVR(value: bool):
	$ARVROrigin.player_camera = (cameraNOVR if not value else cameraVR)
	using_vr = value

func getUsingVR():
	return using_vr
	
func collides_with(object: Node) -> bool:
	for i in range(self.get_slide_count()):
		var current : KinematicCollision = self.get_slide_collision(i)
		if current.collider == object:
			return true
	return false
