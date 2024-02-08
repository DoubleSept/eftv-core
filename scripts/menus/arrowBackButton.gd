extends TextureButton

func _ready():
	if Constants.isVideoMode:
		visible = false

func _on_pressed():
	var _changed = get_tree().change_scene(Constants.SCENE_MENU_MAIN)
