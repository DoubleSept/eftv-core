extends Node

const SAVE_DIR = "user://saves/"
const SAVE_PATH = SAVE_DIR+"save.json"

const KEY_CURRENT_LEVEL = "currentLevel"
const KEY_LEVELS_FINISHED = "levelsFinished"
const KEY_MAX_LEVEL_FINISHED = "maxLevel"

const SAVE_VERSION = 1

var loadedData = false
var gameData : Dictionary = {}
var LevelSystem
var levels = [] # Lazy loading

func _ready():
	var dir = Directory.new()
	if not dir.dir_exists(SAVE_DIR):
		print("Creating SAVE directory")
		dir.make_dir(SAVE_DIR)
	LevelSystem = get_node("/root/LevelSystem")
	self.loadGameData()

func saveGameData():
	var save_file = File.new()
	
	save_file.open(SAVE_PATH, File.WRITE)
	save_file.store_line(JSON.print(gameData))
	
	save_file.close()
	
func loadGameData():
	var save_file = File.new()
	if not save_file.file_exists(SAVE_PATH):
		print("No game data found")
		return
	
	save_file.open(SAVE_PATH, File.READ)
	gameData = JSON.parse(save_file.get_as_text()).result
	
	if not KEY_MAX_LEVEL_FINISHED in gameData:
		gameData[KEY_MAX_LEVEL_FINISHED] = ""
	
	if LevelSystem.TEST_LEVEL != null:
		print("Test level found")
		gameData[KEY_CURRENT_LEVEL] = LevelSystem.TEST_LEVEL
	
	save_file.close()
	loadedData = true
	
func initGameData():
	if LevelSystem.TEST_LEVEL != null:
		print("Test level found")
		gameData[KEY_CURRENT_LEVEL] = LevelSystem.TEST_LEVEL
		var index = LevelSystem.get_index_from_string(gameData[KEY_CURRENT_LEVEL])
		levels = LevelSystem.get_next_levels_array(index)
	else:
		levels = LevelSystem.get_next_levels_array(0)
	gameData[KEY_CURRENT_LEVEL] = levels[0].name
	gameData[KEY_LEVELS_FINISHED] = []
	gameData[KEY_MAX_LEVEL_FINISHED] = ""
	gameData["version"] = SAVE_VERSION
	

func get_current_level():
	if not loadedData:
		loadGameData()
		
	var isFirstGame = gameData.keys().size() < 1
	if isFirstGame:
		initGameData()
	else:
		var index = LevelSystem.get_index_from_string(gameData[KEY_CURRENT_LEVEL])
		levels = LevelSystem.get_next_levels_array(index)
	return levels.front().level
	
func level_finished():
	# Add to finished list
	var finished = levels.front().name
	if not finished in gameData[KEY_LEVELS_FINISHED]:
		gameData[KEY_LEVELS_FINISHED].push_back(finished)
	# Switch current head
	levels.pop_front()
	var newLevel = levels.front()
	
	# Check if it is a new max level reached
	var reachedIndex = LevelSystem.get_index_from_string(newLevel.name)
	var maxLevelIndex = LevelSystem.get_index_from_string(gameData[KEY_MAX_LEVEL_FINISHED])
	if reachedIndex > maxLevelIndex:
		gameData[KEY_MAX_LEVEL_FINISHED] = newLevel.name;
	
	# Edit current and save
	gameData[KEY_CURRENT_LEVEL] = newLevel.name
	saveGameData()
	return newLevel.level