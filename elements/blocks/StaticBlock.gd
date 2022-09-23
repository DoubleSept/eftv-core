tool
extends StaticBody
class_name StaticBlock

export (bool) var is_dark = false setget set_is_dark

func _ready():
	_update_material()

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
