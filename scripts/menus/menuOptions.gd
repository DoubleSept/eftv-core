extends PanelContainer

signal start

func _ready():
	$MarginContainer/VBoxContainer/Continue.grab_focus()
	
func _on_Continue_pressed():
	emit_signal("start")

func _on_Selection_pressed():
	get_tree().set_input_as_handled()
	get_tree().change_scene(Constants.SCENE_MENU_SELECTION)

func _on_Exit_pressed():
	get_tree().quit()

func _on_Demo_pressed():
	SaveSystem.gameData[SaveSystem.KEY_CURRENT_LEVEL] = LevelsList.DEMO_RUN
	emit_signal("start")
