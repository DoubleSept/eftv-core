extends MarginContainer

var logoGrowthDirection = 1.0
var SaveSystem
var isFirstGame = false

onready var logo_partPV = $sections/logoContainer/logo/pv
onready var logo_partFromThe = $sections/logoContainer/logo/fromThe

onready var LOADING_MENU = $sections/menus/loadingScreen
onready var NO_HEADSET = $sections/menus/noHeadset
onready var OPTIONS = $sections/menus/options
onready var PRESS_PLAY = $sections/menus/PressToPlay

# Called when the node enters the scene tree for the first time.
func _ready():
	# Check if it is first launch
	SaveSystem = get_node("/root/SaveSystem")
	
	# Enable input
	set_process_input(true)
		
func _input(event):
	if(event.is_action_pressed("ui_cancel")):
		get_tree().quit()

func _on_switchMenu(displayMenu : Control):
	print_debug("Switch to menu: ", displayMenu.name)
	
	$sections/menus/options.visible = false
	$sections/menus/loadingScreen.visible = false
	$sections/menus/PressToPlay.visible = false
	$sections/menus/noHeadset.visible = false
	
	displayMenu.visible = true

func _on_noHeadset():
	_on_switchMenu(NO_HEADSET)

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
