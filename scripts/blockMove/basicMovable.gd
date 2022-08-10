tool
extends KinematicBody

export (Color) var mesh_color = Color(0,0.5,1.0) setget set_mesh_color
export (float) var max_speed = 20
export (float) var min_movement = 0.05

var is_movable = true
var sound_playing = false
var hovered = false
onready var player : Node

var targetPosition = null
var _cancelAxisX: bool = false
var _cancelAxisY: bool = false
var _cancelAxisZ: bool = false

func _ready():
	set_mesh_color(mesh_color)

	if not Engine.editor_hint:
		player = get_tree().get_current_scene().find_node("player", true, false)
		if player == null:
			print_debug("Player cannot be found")

## Passer à un système de target
func _physics_process(delta):
	if targetPosition == null:
		set_physics_process(false)
		return

	var moveVector = targetPosition - self.global_transform.origin

	if _cancelAxisX:
		moveVector.x = 0
	if _cancelAxisY:
		moveVector.y = 0
	if _cancelAxisZ:
		moveVector.z = 0

	if(moveVector.length() > max_speed):
		moveVector = (max_speed/moveVector.length()) * moveVector

	if move_and_collide(moveVector, false, true, false) != null:
		move_and_collide(Vector3(moveVector.x, 0, 0), false, true, false)
		move_and_collide(Vector3(0, moveVector.y, 0), false, true, false)
		move_and_collide(Vector3(0, 0, moveVector.z), false, true, false)

func move(newTargetPosition: Vector3, cancelAxisX = false, cancelAxisY = false, cancelAxisZ = false):
	if not Engine.editor_hint:
		if player.collides_with(self):
			if not sound_playing:
				sound_playing = true
				$denySound.play()
			targetPosition = null
			return

	_cancelAxisX = cancelAxisX
	_cancelAxisY = cancelAxisY
	_cancelAxisZ = cancelAxisZ

	targetPosition = newTargetPosition

	set_physics_process(true)

func _on_denySound_finished():
	sound_playing = false
	pass # Replace with function body.

func _on_release():
	targetPosition = null

func _hovered():
	hovered = true

func _unhovered():
	hovered = false

func set_mesh_color(color):
	mesh_color = color
	var newMaterial = load("res://eftv-core/assets/textures/metalCoude.tres").duplicate()
	newMaterial.albedo_color = mesh_color
	for node in get_children():
		if(node.get_class() == "MeshInstance"):
			node.material_override = newMaterial
