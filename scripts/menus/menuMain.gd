extends MarginContainer

var logoGrowthDirection = 1.0
var SaveSystem
var isFirstGame = false

# Called when the node enters the scene tree for the first time.
func _ready():
	# Check if it is first launch
	SaveSystem = get_node("/root/SaveSystem")
	isFirstGame = SaveSystem.gameData.keys().size() < 1
	
	# Disable options in first game
	if isFirstGame:
		$sections/menus/bt_PressToPlay.visible = true
	else:
		$sections/menus/options.visible = true
		$sections/menus.remove_child($sections/menus/bt_PressToPlay)
	
	# Enable input
	set_process_input(true)
	
func _process(delta):
	var pv_new_scale = $sections/pv.scale.x - logoGrowthDirection *delta*0.01
	$sections/pv.scale = Vector2(pv_new_scale, pv_new_scale)
	
	var from_new_scale = $sections/fromThe.scale.x - logoGrowthDirection *delta*0.02
	$sections/fromThe.scale = Vector2(from_new_scale, from_new_scale)
	
	# Change direction when necessary
	if pv_new_scale < 0.34 or pv_new_scale > 0.37:
		logoGrowthDirection = logoGrowthDirection * (-1.0)
		
func _input(event):
	if(event.is_action("ui_cancel")):
		get_tree().quit()

func _on_switchMenu(newMenu):
	print_debug("Switch to menu: ", newMenu)
	
	$sections/menus/levelsMenu.visible = false
	$sections/menus/options.visible = false
	$sections/menus/loadingScreen.visible = false
	
	if($sections/menus.has_node("bt_PressToPlay")):
		$sections/menus/bt_PressToPlay.visible = false
	
	$sections/menus/options.set_process_input(false)
	
	if newMenu == "options":
		$sections/menus/options.visible = true
		$sections/menus/options.set_process_input(true)
	elif newMenu == "levelsMenu":
		$sections/menus/levelsMenu.visible = true
	elif newMenu == "loading":
		$sections/menus/loadingScreen.visible = true


func _on_noHeadset():
	if($sections/menus.has_node("bt_PressToPlay")):
		$sections/menus/bt_PressToPlay.visible = false
	$sections/menus/levelsMenu.visible = false
	$sections/menus/options.visible = false
	$sections/menus/loadingScreen.visible = false
	$sections/menus/options.set_process_input(false)
	
	$sections/menus/noHeadset.visible = true

func _on_exit_button_pressed():
	get_tree().quit()
