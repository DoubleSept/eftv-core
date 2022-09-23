extends MarginContainer

func _ready():
	#Start with focus on accept
	$Margin/Parts/Buttons/Accept.grab_focus()
	if(Constants.isEditor):
		get_tree().change_scene(Constants.SCENE_MENU_MAIN)

func start_game():
	var _scene_changed = get_tree().change_scene(Constants.SCENE_MENU_MAIN)

func _on_Exit_pressed():
	get_tree().quit()

func _on_Accept_pressed():
	print("ACCEPT TELEMETRY")
	SaveSystem.gameData[SaveSystem.KEY_ALLOW_TELEMETRY] = true
	start_game()

func _on_Deny_pressed():
	print("DENY TELEMETRY")
	SaveSystem.gameData[SaveSystem.KEY_ALLOW_TELEMETRY] = false
	start_game()
