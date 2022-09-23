extends Area

onready var triggered = false

func _ready():
	pass

func _on_body_entered(body: Node):
	print_debug("End sphere: "+body.name)
	if(body.get_name() == "player" and triggered == false):
		triggered = true
		get_tree().get_current_scene()._on_sceneNode_level_finished()
