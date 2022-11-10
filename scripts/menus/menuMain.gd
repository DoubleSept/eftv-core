extends MarginContainer

signal newTranslation

var logoGrowthDirection = 1.0
var SaveSystem
var isFirstGame = false

onready var menus_node = $sections/menus
onready var tag_line = find_node("TagLine")

var mainMenu = find_node("baseMenu")

func _ready():
	# Check if it is first launch
	SaveSystem = get_node("/root/SaveSystem")

	# Enable input
	set_process_input(true)

	if ((SaveSystem.gameData[SaveSystem.KEY_LEVELS_INFOS_MS].size() == 0)
		or ("IS_DEMO" in LevelsList and LevelsList.IS_DEMO)):
		mainMenu = find_node("firstGame")
	else:
		mainMenu = find_node("baseMenu")
	_on_switchMenu(mainMenu)

	if LevelsList.TAGLINE != null:
		tag_line.visible = true
		tag_line.text = LevelsList.TAGLINE
	else:
		tag_line.visible = false



func _input(event):
	if(event.is_action_pressed("ui_cancel")):
		get_tree().quit()

func _on_switchMenu(displayMenu : Control):
	print_debug("Switch to menu: ", displayMenu.name)

	for node in menus_node.get_children():
		node.visible = false

	displayMenu.visible = true

func _on_exit_button_pressed():
	get_tree().quit()

func _on_start():
	LevelSystem.IsDemoMode = false
	if not (SaveSystem.KEY_CURRENT_LEVEL in SaveSystem.gameData):
		SaveSystem.gameData[SaveSystem.KEY_CURRENT_LEVEL] = LevelsList.LIST.front()
	SaveSystem.start_run()
	_on_switchMenu(find_node("loading"))
	var _changed = get_tree().change_scene(Constants.SCENE_MAIN)

func _on_noHeadset():
	_on_switchMenu(find_node("noHeadset"))

func _on_settings():
	_on_switchMenu(find_node("settings"))

func _on_baseMenu():
	_on_switchMenu(mainMenu)

func _on_selection_pressed():
	get_tree().set_input_as_handled()
	var _changed = get_tree().change_scene(Constants.SCENE_MENU_SELECTION)

func _on_demo_pressed():
	LevelSystem.IsDemoMode = true
	_on_switchMenu(find_node("loading"))
	SaveSystem.start_run()
	var _changed = get_tree().change_scene(Constants.SCENE_MAIN)

func _on_exit():
	get_tree().quit()

func _on_newTranslation():
	emit_signal("newTranslation")
