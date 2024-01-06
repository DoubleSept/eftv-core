extends MarginContainer

signal runChanged(id, name, recordStr)

var SaveSystem
var currentId = null
var current_index = 0

onready var titleNode = $recordBox/Vbox/Title
onready var timeNode = $recordBox/Vbox/Time
onready var recordNode = $recordBox/Vbox/Record
onready var startNode = $recordBox/Vbox/Start

var levelsList = []
var levelsRoot = ""

func _ready():
	SaveSystem = get_node("/root/SaveSystem")

	titleNode.text = tr("TEXT_LOADING")
	timeNode.text = "00:00"
	startNode.grab_focus()
	
	if(LevelSystem.IsDemoMode):
		levelsList = LevelSystem.loadExtras()
		levelsRoot = LevelSystem.LEVELS_ROOT+"extras/"
	else:
		levelsList = LevelSystem.LEVELS_LIST
		levelsRoot = LevelSystem.LEVELS_ROOT

	update_infos()

func _on_backToMenu_pressed():
	get_tree().change_scene(Constants.SCENE_MENU_MAIN)

func _on_run_changed(id, name, recordStr, hasPrevious, hasNext, hasSecretEnabled = false):
	$MarginContainer/GoBack.visible = hasPrevious
	$MarginContainer/GoNext.visible = hasNext

	if recordStr == null:
		timeNode.visible = false
		recordNode.text = tr("TEXT_NO_RECORD")
	else:
		recordNode.text = tr("TEXT_RECORD")
		timeNode.visible = true
		timeNode.text = recordStr
	titleNode.text = name

	var directory = Directory.new();
	var previewPath = levelsRoot+id+"/preview.png"
	if ResourceLoader.exists(previewPath):
		$Preview.texture = load(previewPath)
	else:
		$Preview.texture = load(LevelSystem.LEVELS_ROOT+"defaultPreview.png")
	currentId = id

	get_node("%Secret").visible = hasSecretEnabled

func _on_Start_pressed():
	SaveSystem.start_run(currentId, false, LevelSystem.IsDemoMode)
	get_tree().change_scene(Constants.SCENE_MAIN)

func _on_GoNext_pressed():
	current_index = current_index + 1
	update_infos()

func _on_GoBack_pressed():
	current_index = current_index - 1
	update_infos()

func update_infos():
	var runId = levelsList[current_index]
	var runInfos : RunInfos = LevelSystem.get_run_infos(runId, false, LevelSystem.IsDemoMode)

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
		
	var has_next: bool
	if LevelSystem.IsDemoMode:
		has_next = current_index < len(levelsList) - 1
	else:
		has_next = runInfos.hasNextRun && runId != maxLevel

	_on_run_changed(runId,
		runInfos.name,
		recordStr,
		current_index > 0,
		has_next,
		runId in SaveSystem.gameData[SaveSystem.KEY_SECRET]
		)

	emit_signal("runChanged", runId, runInfos.name, recordStr)


func _on_Secret_pressed():
	SaveSystem.start_run(currentId, true, LevelSystem.IsDemoMode)
	get_tree().change_scene(Constants.SCENE_MAIN)
