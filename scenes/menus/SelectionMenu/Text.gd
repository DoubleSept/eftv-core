extends MarginContainer

signal runChanged(id, name, recordStr)

var SaveSystem
var currentId = null
var current_index = 0

func _ready():
	SaveSystem = get_node("/root/SaveSystem")
	
	$recordBox/recordInside/Vbox/Title.text = tr("TEXT_LOADING")
	$recordBox/recordInside/Vbox/Time.text = "00:00"
	
	$recordBox/recordInside/Vbox/Start.grab_focus()
	
	update_infos()

func _on_backToMenu_pressed():
	get_tree().change_scene(Constants.SCENE_MENU_MAIN)
	
func _on_run_changed(id, name, recordStr, hasPrevious, hasNext):
	$MarginContainer/GoBack.visible = hasPrevious
	$MarginContainer/GoNext.visible = hasNext
	
	if recordStr == null:
		$recordBox/recordInside/Vbox/Time.visible = false
		$recordBox/recordInside/Vbox/Record.text = 'No Record'
	else:
		$recordBox/recordInside/Vbox/Record.text = 'Current Record'
		$recordBox/recordInside/Vbox/Time.visible = true
		$recordBox/recordInside/Vbox/Time.text = recordStr
	$recordBox/recordInside/Vbox/Title.text = name
	
	var directory = Directory.new();
	var previewPath = LevelSystem.LEVELS_ROOT+id+"/preview.png"
	if ResourceLoader.exists(previewPath):
		$Preview.texture = load(previewPath)
	else:
		$Preview.texture = load(LevelSystem.LEVELS_ROOT+"defaultPreview.png")
	currentId = id

func _on_Start_pressed():
	SaveSystem.gameData[SaveSystem.KEY_CURRENT_LEVEL] = currentId
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
	
	var maxLevel = SaveSystem.gameData[SaveSystem.KEY_MAX_LEVEL_FINISHED]
	
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
		runInfos.hasNextRun && runId != maxLevel)
		
	emit_signal("runChanged", runId, runInfos.name, recordStr)
