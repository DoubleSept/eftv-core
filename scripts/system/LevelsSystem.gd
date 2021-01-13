extends Node

const LEVELS_ROOT = "res://levels/"

# For debug purposes: you can specify a level that will by displayed at launch
const TEST_LEVEL = null

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
func get_run_infos(runName: String):
	# Load level
	var runPath = LEVELS_ROOT+runName+'/'
	var run = load(runPath+'infos.gd').new()
	var levelList = run.getLevelList()
	
	var runIndex = get_index_from_string(runName)
	var hasNextRun = runIndex < (LEVELS_LIST.size() - 1)
	
	print(runIndex, "/", LEVELS_LIST.size(), "/", hasNextRun)
	
	var runInfos = {
		'id': runName, 
		'index': runIndex,
		'name': run.getTitle(),
		'hasNextRun': hasNextRun, 
		'levels': []}
		
	for x in range(0, levelList.size()):
		runInfos.levels.push_back(load(runPath + 'levels/' + levelList[x]))
	return runInfos
