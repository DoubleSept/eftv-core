extends "res://eftv-core/scripts/menus/button.gd"

signal switchMenu(newMenu)

func _ready():
	set_process_input(true)


func _input(event : InputEvent):
	if (event is InputEventKey and event.scancode == KEY_SPACE):
		startGame()

func startGame():
	print("Loading game for first time")
	# Go to game
	emit_signal("switchMenu", "loading")
	
	# Wait for text to be changed
	var t = Timer.new()
	t.set_wait_time(0.1)
	t.set_one_shot(true)
	self.add_child(t)
	t.start()
	yield(t, "timeout")
	
	# Change scene
	print("Start: ",get_tree().change_scene(Constants.SCENE_MAIN))
