extends MarginContainer

var logoGrowthDirection = 1.0
var SaveSystem
var isFirstGame = false

onready var logo_partPV = $sections/logoContainer/logo/pv
onready var logo_partFromThe = $sections/logoContainer/logo/fromThe

onready var LOADING_MENU = $sections/menus/loadingScreen
onready var NO_HEADSET = $sections/menus/noHeadset
onready var BASE_MENU = $sections/menus/baseMenu
onready var FIRST_GAME = $sections/menus/firstGame
onready var SETTINGS_MENU = $sections/menus/SettingsMenu

# Called when the node enters the scene tree for the first time.
func _ready():
	# Check if it is first launch
	SaveSystem = get_node("/root/SaveSystem")
	
	# Enable input
	set_process_input(true)
	
	if SaveSystem.gameData[SaveSystem.KEY_LEVELS_INFOS_MS].size() == 0:
		_on_switchMenu(FIRST_GAME)
	else:
		_on_switchMenu(BASE_MENU)
		
func _input(event):
	if(event.is_action_pressed("ui_cancel")):
		get_tree().quit()

func _on_switchMenu(displayMenu : Control):
	print_debug("Switch to menu: ", displayMenu.name)
	
	BASE_MENU.visible = false
	LOADING_MENU.visible = false
	FIRST_GAME.visible = false
	NO_HEADSET.visible = false
	SETTINGS_MENU.visible = false
	
	displayMenu.visible = true

func _on_exit_button_pressed():
	get_tree().quit()

func _on_start():
	_on_switchMenu(LOADING_MENU)
	var _changed = get_tree().change_scene(Constants.SCENE_MAIN)

# LOGO ANIMATION
func _process(delta):
	var pv_new_scale = logo_partPV.scale.x - logoGrowthDirection *delta*0.01
	logo_partPV.scale = Vector2(pv_new_scale, pv_new_scale)
	
	var from_new_scale = logo_partFromThe.scale.x - logoGrowthDirection *delta*0.02
	logo_partFromThe.scale = Vector2(from_new_scale, from_new_scale)
	
	# Change direction when necessary
	if pv_new_scale < 0.34 or pv_new_scale > 0.37:
		logoGrowthDirection = logoGrowthDirection * (-1.0)

func _on_noHeadset():
	_on_switchMenu(NO_HEADSET)

func _on_settings():
	_on_switchMenu(SETTINGS_MENU)

func _on_baseMenu():
	_on_switchMenu(BASE_MENU)

func _on_exit():
	get_tree().quit()
