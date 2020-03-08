extends Node

const LEVELS_ROOT = "res://levels/"

# For debug purposes: you can specify a level that will by displayed at launch
const TEST_LEVEL = null

const LEVELS_LIST = LevelsList.LIST

func get_index_from_string(search: String):
	for x in range(LEVELS_LIST.size()):
		var level_name = LEVELS_LIST[x][0]
		if level_name == search:
			return x
	# If not found, we return index 0
	# If not found, we return index 0
	return 0
	
# Load all levels from specified index
# Array elements are of type: [name: String, level: Resource]
func get_next_levels_array(index: int):
	var levels = []
	for x in range(index, LEVELS_LIST.size()):
		levels.push_back({ 
			"name": LEVELS_LIST[x][0], 
			"level": load(LEVELS_ROOT + LEVELS_LIST[x][1])
			})
	return levels