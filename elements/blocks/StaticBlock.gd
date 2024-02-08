tool
extends StaticBody
class_name StaticBlock

export (bool) var is_dark = false setget set_is_dark
export var is_visible_ortho = true setget set_visible_ortho
export var is_visible_headset = true setget set_visible_headset

func _ready():
	_update_material()
	set_visible_ortho(is_visible_ortho)

func _update_material():
	var newMaterial = load("res://eftv-core/assets/textures/metal.tres").duplicate()
	if (is_dark):
			newMaterial.metallic =  0.7
			newMaterial.metallic =  0.6
			newMaterial.roughness = 0
	for node in get_children():
		if node is MeshInstance:
			node.material_override = newMaterial

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
