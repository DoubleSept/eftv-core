extends Node

const SAVE_DIR = "user://saves/"
const SAVE_PATH = SAVE_DIR+"save.json"

const KEY_ALLOW_TELEMETRY = "telemetry"
const KEY_UUID = "uuid"
const KEY_CURRENT_LEVEL = "currentLevel"
const KEY_MAX_LEVEL_FINISHED = "maxLevel"
const KEY_LEVELS_INFOS_MS = "levelsInfos"

const SAVE_VERSION = 2

var loadedData = false
var gameData : Dictionary = {}
var LevelSystem
var runInfos = {} # Lazy loading

var runStartMs
var runTitle
var runDurationMs

var requestNode = null
var isFirstGame = false

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
		initGameData()
		isFirstGame = true
		return
	
	save_file.open(SAVE_PATH, File.READ)
	gameData = JSON.parse(save_file.get_as_text()).result
	
	# Check if previous version
	if gameData.version == 1:
		initGameData()
		gameData[KEY_MAX_LEVEL_FINISHED] = LevelsList.LIST[LevelsList.LIST.size() - 1]
		gameData[KEY_CURRENT_LEVEL] = LevelsList.FROM_VERSION_1
	else :
		if not KEY_MAX_LEVEL_FINISHED in gameData:
			gameData[KEY_MAX_LEVEL_FINISHED] = ""
		
		if LevelSystem.TEST_LEVEL != null:
			print("Test level found")
			gameData[KEY_CURRENT_LEVEL] = LevelSystem.TEST_LEVEL
		
		save_file.close()
		loadedData = true
		
		# Send launch infos
		if gameData[KEY_ALLOW_TELEMETRY]:
			requestNode = HTTPRequest.new()
			add_child(requestNode)
			requestNode.connect("request_completed", self, "_request_completed")
		
			var error = requestNode.request(
				LevelsList.URL_TELEMETRY+ "launch/"+ gameData[KEY_UUID],
				[], true, HTTPClient.METHOD_POST)
	
func initGameData():
	if LevelSystem.TEST_LEVEL != null:
		print("Test level found")
		gameData[KEY_CURRENT_LEVEL] = LevelSystem.TEST_LEVEL
	else:
		gameData[KEY_CURRENT_LEVEL] = LevelsList.LIST[0]
	gameData[KEY_LEVELS_INFOS_MS] = {}
	gameData[KEY_MAX_LEVEL_FINISHED] = LevelsList.LIST[0]
	gameData[KEY_ALLOW_TELEMETRY] = true
	gameData["version"] = SAVE_VERSION
	
	# Get an UUID
	requestNode = HTTPRequest.new()
	add_child(requestNode)
	requestNode.connect("request_completed", self, "_uuid_request_completed")

	var error = requestNode.request(LevelsList.URL_TELEMETRY+ "new", PoolStringArray(), true, HTTPClient.METHOD_POST)
	
	loadedData = true
	
func _uuid_request_completed(result, response_code, headers, body):
	var uuid = body.get_string_from_utf8()
	if response_code == 200:
		gameData[KEY_UUID] = uuid
		saveGameData()
	remove_child(requestNode)
	requestNode = null

func run_finished():
	var runId = runInfos.id
	if not runId in gameData[KEY_LEVELS_INFOS_MS].keys():
		gameData[KEY_LEVELS_INFOS_MS][runId] = runDurationMs
	elif runDurationMs < gameData[KEY_LEVELS_INFOS_MS][runId] :
		# New record
		gameData[KEY_LEVELS_INFOS_MS][runId] = runDurationMs

	# Check if it is a new max level reached
	var reachedIndex = LevelSystem.get_index_from_string(runId)
	var maxLevelIndex = LevelSystem.get_index_from_string(gameData[KEY_MAX_LEVEL_FINISHED])
	if reachedIndex > maxLevelIndex:
		gameData[KEY_MAX_LEVEL_FINISHED] = runId;
	
	# Edit current and save
	if(runInfos.hasNextRun):
		gameData[KEY_CURRENT_LEVEL] = LevelSystem.LEVELS_LIST[runInfos.index + 1]
	
	saveGameData()
	
	# Send run infos
	if gameData[KEY_ALLOW_TELEMETRY]:
		requestNode = HTTPRequest.new()
		add_child(requestNode)
		requestNode.connect("request_completed", self, "_request_completed")
	
		var error = requestNode.request(
			LevelsList.URL_TELEMETRY+ "run/"+ gameData[KEY_UUID],
			["Content-Type: application/json"], 
			true, 
			HTTPClient.METHOD_POST,
			JSON.print({'levelName': runInfos.id, 'timeMs': runDurationMs}))

func _request_completed(result, response_code, headers, body):
	remove_child(requestNode)
	requestNode = null
	
func start_run():
	if not loadedData:
		loadGameData()
	
	runInfos = LevelSystem.get_run_infos(gameData[KEY_CURRENT_LEVEL])
	print(gameData[KEY_CURRENT_LEVEL], runInfos.levels.size())
	runStartMs = OS.get_ticks_msec()
	return runInfos.levels.front()

func level_finished():
	runInfos.levels.pop_front()
	if runInfos.levels.size() > 0:
		# Run is not finished
		return runInfos.levels.front()
	
	# Run is finished
	runDurationMs = OS.get_ticks_msec() - runStartMs
	return null
