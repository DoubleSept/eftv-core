extends Spatial

var current_index = 0

func _ready():
	current_index = 0
	update_infos()

func _next():
	current_index = current_index + 1
	update_infos()

func _previous():
	current_index = current_index - 1
	update_infos()

func update_infos():
	var runId = LevelSystem.LEVELS_LIST[current_index]
	var runInfos = LevelSystem.get_run_infos(runId)
	
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
	
	$MenuText._on_run_changed(runId, 
		runInfos.name, 
		recordStr, 
		current_index > 0, 
		runInfos.hasNextRun && runId != maxLevel)
	$viewportPlayer/MenuHeadset._on_run_changed(runId, 
		runInfos.name, 
		recordStr, 
		current_index > 0, 
		runInfos.hasNextRun && runId != maxLevel)