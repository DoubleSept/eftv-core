extends TextureButton

func _on_pressed():
	var _changed = get_tree().change_scene(Constants.SCENE_MENU_MAIN)
