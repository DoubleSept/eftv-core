tool
extends KinematicBody
class_name BasicMovable

signal released

export (Color) var mesh_color = Color(0,0.5,1.0) setget set_mesh_color
export (bool) var is_dark = false setget set_is_dark

export (float) var max_speed = 20
export (float) var min_movement = 0.05

export var is_visible_ortho = true setget set_visible_ortho
export var is_visible_headset = true setget set_visible_headset

var is_movable = true
var sound_playing = false
var hovered = false
onready var player : Node

var targetPosition = null
var selectionDeltaPosition : Vector3 = Vector3(0,0,0)
var _cancelAxisX: bool = false
var _cancelAxisY: bool = false
var _cancelAxisZ: bool = false

const LERP_SPEED := 2.0

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
	
	var eTarget = targetPosition - selectionDeltaPosition
	var eSelf = self.global_translation

	if _cancelAxisX:
		eTarget.x = 0
		eSelf.x = 0
	if _cancelAxisY:
		eTarget.y = 0
		eSelf.y = 0
	if _cancelAxisZ:
		eTarget.z = 0
		eSelf.z = 0
		
	var moveVector = lerp(eTarget, eSelf, LERP_SPEED*delta) - eSelf

	if(moveVector.length() > max_speed):
		moveVector = (max_speed/moveVector.length()) * moveVector

	if move_and_collide(moveVector, false, true, false) != null:
		move_and_collide(Vector3(moveVector.x, 0, 0), false, true, false)
		move_and_collide(Vector3(0, moveVector.y, 0), false, true, false)
		move_and_collide(Vector3(0, 0, moveVector.z), false, true, false)

func _on_select(newTargetPosition: Vector3, cancelAxisX = false, cancelAxisY = false, cancelAxisZ = false):
	selectionDeltaPosition = newTargetPosition - self.global_translation
	print("DELTA: %s" % selectionDeltaPosition)
	
func move(newTargetPosition: Vector3, cancelAxisX = false, cancelAxisY = false, cancelAxisZ = false):
	if not Engine.editor_hint:
		if player.last_movable_floor() == self:
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
	emit_signal("released")
	targetPosition = null
	selectionDeltaPosition = Vector3(0,0,0)

func _hovered():
	hovered = true

func _unhovered():
	hovered = false

func _update_material():
	var newMaterial = load("res://eftv-core/assets/textures/metal.tres").duplicate()
	newMaterial.albedo_color = mesh_color
	if (is_dark):
			newMaterial.metallic =  0.7
			newMaterial.metallic =  0.6
			newMaterial.roughness = 0
	for node in get_children():
		if node is MeshInstance:
			node.material_override = newMaterial

func set_mesh_color(color):
	mesh_color = color
	_update_material()

func set_is_dark(new_value):
	if new_value != is_dark:
		is_dark = new_value
		_update_material()

func set_visible_ortho(new_visible):
	is_visible_ortho = new_visible
	$mesh.set_layer_mask_bit(1, new_visible)

func set_visible_headset(new_visible):
	is_visible_headset = new_visible
	$mesh.set_layer_mask_bit(0, new_visible)
