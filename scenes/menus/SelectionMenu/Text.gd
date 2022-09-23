extends MarginContainer

signal runChanged(id, name, recordStr)

var SaveSystem
var currentId = null
var current_index = 0

onready var titleNode = $recordBox/Vbox/Title
onready var timeNode = $recordBox/Vbox/Time
onready var recordNode = $recordBox/Vbox/Record
onready var startNode = $recordBox/Vbox/Start

func _ready():
	SaveSystem = get_node("/root/SaveSystem")

	titleNode.text = tr("TEXT_LOADING")
	timeNode.text = "00:00"
	startNode.grab_focus()

	update_infos()

func _on_backToMenu_pressed():
	get_tree().change_scene(Constants.SCENE_MENU_MAIN)

func _on_run_changed(id, name, recordStr, hasPrevious, hasNext, hasSecretEnabled = false):
	$MarginContainer/GoBack.visible = hasPrevious
	$MarginContainer/GoNext.visible = hasNext

	if (Steam.is_init()):
		print("New test: %s (%s)" % [Steam.get_achievement("TEST_2"), Steam.user_stats.get_stat("test_menu")])
		Steam.set_achievement("TEST_2")
		Steam.user_stats.set_stat("test_menu", 2)

	if recordStr == null:
		timeNode.visible = false
		recordNode.text = tr("TEXT_NO_RECORD")
	else:
		recordNode.text = tr("TEXT_RECORD")
		timeNode.visible = true
		timeNode.text = recordStr
	titleNode.text = name

	var directory = Directory.new();
	var previewPath = LevelSystem.LEVELS_ROOT+id+"/preview.png"
	if ResourceLoader.exists(previewPath):
		$Preview.texture = load(previewPath)
	else:
		$Preview.texture = load(LevelSystem.LEVELS_ROOT+"defaultPreview.png")
	currentId = id

	get_node("%Secret").visible = hasSecretEnabled

func _on_Start_pressed():
	SaveSystem.start_run(currentId)
	get_tree().change_scene(Constants.SCENE_MAIN)

func _on_GoNext_pressed():
	current_index = current_index + 1
	update_infos()

func _on_GoBack_pressed():
	current_index = current_index - 1
	update_infos()

func update_infos():
	var runId = LevelSystem.LEVELS_LIST[current_index]
	var runInfos : RunInfos = LevelSystem.get_run_infos(runId)

	var maxLevel = SaveSystem.gameData[SaveSystem.KEY_MAX_LEVEL_AVAILABLE]

	# Record string
	var durationMs = null
	if runId in SaveSystem.gameData[SaveSystem.KEY_LEVELS_INFOS_MS]:
		durationMs = SaveSystem.gameData[SaveSystem.KEY_LEVELS_INFOS_MS][runId]
	var recordStr = null
	if durationMs != null && durationMs > 0:
		var minutes = durationMs / 60000
		var seconds = (int(durationMs) % 60000) / 1000
		recordStr = "%02d:%02d" % [minutes, seconds]

	_on_run_changed(runId,
		runInfos.name,
		recordStr,
		current_index > 0,
		runInfos.hasNextRun && runId != maxLevel,
		runId in SaveSystem.gameData[SaveSystem.KEY_SECRET]
		)

	emit_signal("runChanged", runId, runInfos.name, recordStr)


func _on_Secret_pressed():
	SaveSystem.start_run(currentId, true)
	get_tree().change_scene(Constants.SCENE_MAIN)
