extends Node

const LEVELS_ROOT = "res://levels/"

# For debug purposes: you can specify a level that will by displayed at launch
const TEST_LEVEL = null
#const TEST_LEVEL = "00-demo"

var IsDemoMode = false

const LEVELS_LIST = LevelsList.LIST

func get_index_from_string(search: String):
	for x in range(LEVELS_LIST.size()):
		var level_name = LEVELS_LIST[x]
		if level_name == search:
			return x
	# If not found, we return index 0
	return 0
	
# Load all levels from specified index
# Array elements are of type: [name: String, level: Resource]
func get_run_infos(runName: String) -> RunInfos:
	# Load level
	var runPath = LEVELS_ROOT+runName+'/'
	var run = load(runPath+'infos.gd').new()

	var runInfos : RunInfos = RunInfos.new()
	runInfos.id = runName
	runInfos.index = get_index_from_string(runName)
	runInfos.hasNextRun = runInfos.index < (LEVELS_LIST.size() - 1)
	runInfos.name = run.getTitle()

	# Add level path list
	runInfos.levels = []
	var levelList = run.getLevelList()
	for x in range(0, levelList.size()):
		runInfos.levels.push_back(runPath + 'levels/' + levelList[x])

	return runInfos
