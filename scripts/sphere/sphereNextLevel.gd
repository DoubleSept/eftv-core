extends Area

onready var sceneNode = get_tree().get_current_scene()

func _ready():
	pass 

func _on_body_entered(body: Node):
	print_debug("Entering End Sphere")
	if(body.get_name() == "player"):
		sceneNode._on_sceneNode_level_finished()
