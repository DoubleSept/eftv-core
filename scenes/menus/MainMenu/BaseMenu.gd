extends VBoxContainer

func _ready() -> void:
	#Show Extras if player has some (more than just demo)
	var has_extras = len(LevelSystem.loadExtras()) > 1
	$VBoxContainer/Extras.visible = has_extras
	$VBoxContainer/Demo.visible = not has_extras
