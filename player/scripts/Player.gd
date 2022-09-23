extends KinematicBody
class_name EftvPlayer

signal player_fall

export (bool) var can_move = true setget set_can_move

onready var cameraVR : ARVRCamera = $ARVROrigin/Player_Camera
onready var cameraNOVR : Camera = $ARVROrigin/NoVR_Camera
onready var player_triangle = $Triangle
onready var current_camera = cameraVR
var using_vr : bool = true setget set_using_vr

# Gravity Constants
var g = -39.8
var vel = Vector3()
const ACCEL= 3
const DEACCEL= 4

export var jump_speed = 19.0
export var max_speed = 350.0
export var movement_speed = 8.5
export var can_jump = true setget set_can_jump
export var spotlight_enabled = false setget set_spotlight
export var spotlight_angle = 30 setget set_spotlight_angle
export var spotlight_range = 40 setget set_spotlight_range

var last_movable_floor: BasicMovable = null

func _ready():
	set_physics_process(can_move)
	set_using_vr(Constants.useVR)
	updateMovementType()

func updateMovementType():
	$Function_Movement_Both_Hand.move_type = SaveSystem.gameData[SaveSystem.KEY_MOVEMENT_TYPE] as int

func _physics_process(delta):
	# Reset when falling
	if(get_global_translation().y < -25):
		print("Player is falling")
		emit_signal("player_fall")

	if(player_triangle):
		player_triangle.rotation = Vector3(player_triangle.rotation.x,
			current_camera.rotation.y,
			0)

	do_gravity(delta)

	# When we touch the floor, we want to block the last movable that were on our feet (the lowest one on Y-axis
	if self.get_slide_count():
		var lowestElmt = null
		for i in range(self.get_slide_count()):
			var current : KinematicCollision = self.get_slide_collision(i)
			if current.collider is BasicMovable:
				var movable: BasicMovable = current.collider
				if lowestElmt == null or movable.global_translation.y < lowestElmt.global_translation.y:
					lowestElmt = movable
		last_movable_floor = lowestElmt


func do_gravity(delta):
	var dir = Vector3() # Where does the player intend to walk to

	dir.y = 0
	dir = dir.normalized()

	vel.y += delta * g

	var hvel = vel
	hvel.y = 0

	var target = dir * max_speed * delta
	var accel
	if (dir.dot(hvel) > 0):
		accel = ACCEL
	else:
		accel = DEACCEL

	hvel = hvel.linear_interpolate(target, accel * delta)

	vel.x = hvel.x
	vel.z = hvel.z

	vel = move_and_slide(vel,Vector3(0,1,0))

func jump():
	vel.y = jump_speed

func set_can_jump(new_can_jump: bool):
	can_jump = new_can_jump
	$Function_Movement_Both_Hand.canJump = new_can_jump
	$Function_Movement_NoVR.canJump = new_can_jump

func set_can_move(new_move: bool):
	can_move = new_move
	set_physics_process(can_move)
	if can_move && using_vr:
		$Function_Movement_Both_Hand.set_enabled(true)
		$Function_Movement_NoVR.set_enabled(false)
	elif can_move && not using_vr:
		$Function_Movement_Both_Hand.set_enabled(false)
		$Function_Movement_NoVR.set_enabled(true)
		print("NoVr enabled")
	else:
		$Function_Movement_Both_Hand.set_enabled(false)
		$Function_Movement_NoVR.set_enabled(false)

func set_using_vr(value: bool):
	using_vr = value
	cameraNOVR.current = not using_vr
	cameraVR.current = using_vr

	if(value == false):
		$Function_Movement_NoVR.set_camera(cameraNOVR)

	# Update move function
	set_can_move(can_move)

	current_camera = cameraVR if using_vr else cameraNOVR

func last_movable_floor() -> BasicMovable:
	return last_movable_floor

func _on_Left_Hand_visibility_changed():
	$ARVROrigin/ovr_left_hand.visible = $ARVROrigin/Left_Hand.visible

func _on_Right_Hand_visibility_changed():
	$ARVROrigin/ovr_right_hand.visible = $ARVROrigin/Right_Hand.visible

func set_spotlight(new_spot):
	spotlight_enabled = new_spot
	$ARVROrigin/NoVR_Camera/DarkPlayerSpotlight.visible = true

func set_spotlight_range(new_range):
	spotlight_range = new_range
	$ARVROrigin/NoVR_Camera/DarkPlayerSpotlight.spot_range = spotlight_range

func set_spotlight_angle(new_angle):
	spotlight_angle = new_angle
	$ARVROrigin/NoVR_Camera/DarkPlayerSpotlight.spot_angle = new_angle
