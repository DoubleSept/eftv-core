extends Control

export (int) var trigger_button_id = JOY_VR_TRIGGER

onready var title_node = $Extern/Intern/Elements/Title
onready var descr_node = $Extern/Intern/Elements/Description
onready var next_node = $Extern/Intern/Elements/Next

var player_node
var controllers_nodes = []
var isSwitching = false

var bbcodeStart = "[center]"
var bbcodeEnd = "[/center]"

var body = "5DCDFF"
var titleColor = "FFFF4A"

func _ready():
	updateWindow()

	var currentScene = get_tree().get_root()
	controllers_nodes.append( currentScene.find_node("Left_Hand", true, false))
	controllers_nodes.append( currentScene.find_node("Right_Hand", true, false))
	player_node = currentScene.find_node("Player", true, false)
	print("Code execution")
	$Extern/Intern/Elements/Title/AnimationPlayer.play("TitleShadow")

func updateWindow():
	var mode = SaveSystem.gameData[SaveSystem.KEY_MOVEMENT_TYPE]
	var modeStr = "ROTATION"

	if mode == SaveSystem.MovementTypeEnum.MOVE_AND_STRAFE:
		modeStr = "STRAFE"
	elif mode == SaveSystem.MovementTypeEnum.MOVE_AND_HYBRID:
		modeStr = "HYBRID"

	title_node.bbcode_text = bbcodeStart + tr("MENU_MOVEMENT_%s" % [modeStr]) + bbcodeEnd
	next_node.bbcode_text = bbcodeStart + tr("MENU_TRIGGER_TO_CHANGE") + bbcodeEnd
	descr_node.text = tr("MENU_MOVEMENT_%s_DESCR" % [modeStr])

func get_movement_idx(value):
	var x = 0
	for i in SaveSystem.MovementTypeEnum.values():
		if i == value:
			return x
		x = x+1

func switchType():
	print_debug("Switching movement type")
	var previous_idx = get_movement_idx(SaveSystem.gameData[SaveSystem.KEY_MOVEMENT_TYPE])
	var next_idx = previous_idx + 1
	if next_idx >= SaveSystem.MovementTypeEnum.size():
		next_idx = 0
	SaveSystem.gameData[SaveSystem.KEY_MOVEMENT_TYPE] = SaveSystem.MovementTypeEnum.values()[next_idx]
	player_node.updateMovementType()
	updateWindow()
	SaveSystem.saveGameData()

func _physics_process(delta):
	var some_switching = false
	for controller in controllers_nodes:
		if controller != null && controller.get_is_active():
			if controller.is_button_pressed(trigger_button_id):
				some_switching = true

	if not some_switching:
		isSwitching = false
	elif isSwitching == false:
		switchType()
		isSwitching = true
