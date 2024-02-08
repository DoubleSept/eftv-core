extends Area

onready var triggered = false
export var is_visible_ortho = true setget set_visible_ortho


func _ready():
	pass

func _on_body_entered(body: Node):
	print_debug("End sphere: "+body.name)
	if(body.get_name() == "player" and triggered == false):
		triggered = true
		get_tree().get_current_scene()._on_sceneNode_level_finished()

func set_visible_ortho(new_visible):
	is_visible_ortho = new_visible
	$meshOuter.set_layer_mask_bit(1, new_visible)
	$meshInner.set_layer_mask_bit(1, new_visible)
