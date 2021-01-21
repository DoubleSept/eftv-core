tool
extends KinematicBody

export (Color) var mesh_color = Color(0,0.5,1.0) setget set_mesh_color

var is_movable = true
var sound_playing = false
var hovered = false
onready var player : Node

func _ready():
	set_mesh_color(mesh_color)
	
	if not Engine.editor_hint:
		player = get_tree().get_current_scene().find_node("player", true, false)
		if player == null:
			print_debug("Player cannot be found")
	
func move(moveVector: Vector3):
	if not Engine.editor_hint:
		if player.collides_with(self):
			if not sound_playing:
				sound_playing = true
				$denySound.play()
			return
		
		if move_and_collide(moveVector, false, true, false) != null:
			# Try each axis individually
			move_and_collide(Vector3(moveVector.x, 0, 0), false, true, false)
			move_and_collide(Vector3(0, moveVector.y, 0), false, true, false)
			move_and_collide(Vector3(0, 0, moveVector.z), false, true, false)

func _on_denySound_finished():
	sound_playing = false
	pass # Replace with function body.
	
func _on_release():
	pass
	
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
