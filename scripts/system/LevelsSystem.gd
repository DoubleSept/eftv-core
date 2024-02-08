extends Node

const LEVELS_ROOT = "res://levels/"
const EXTRAS_ROOT = "res://levels/extras/"

# For debug purposes: you can specify a level that will by displayed at launch
const TEST_RUN = null
var TEST_LEVEL = null

var IsDemoMode = false

var IsLevelsModsInitialized = false

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
func get_run_infos(runName: String, secret: bool = false, is_extra: bool = false) -> RunInfos:
	# Load level
	var runPath = (EXTRAS_ROOT if is_extra else LEVELS_ROOT)+runName+'/'
	var run = load(runPath+'infos.gd').new()

	var runInfos : RunInfos = RunInfos.new()
	runInfos.secretFound = false
	runInfos.levels = []

	var levelList
	if not secret:
		runInfos.id = runName
		runInfos.index = get_index_from_string(runName)
		runInfos.hasNextRun = runInfos.index < (LEVELS_LIST.size() - 1)
		runInfos.name = run.getTitle()
		runInfos.isSecret = false
		levelList = run.getLevelList()
	else:
		runInfos.id = runName+"-secret"
		runInfos.index = -1
		runInfos.hasNextRun = false
		runInfos.name = run.getSecretName()
		runInfos.isSecret = true
		levelList = run.getSecretList()

	for x in range(0, levelList.size()):
		var levelPath = runPath + 'levels/' + levelList[x]
		if not ".tscn" in levelPath:
			levelPath += ".tscn"
		runInfos.levels.push_back(levelPath)

	return runInfos
	
func initLevelsMods():
	IsLevelsModsInitialized = true
	
	if OS.has_feature("editor"):
		return
		
	var basDir := OS.get_executable_path().get_base_dir()
	var modDir = basDir.plus_file("mods")
	var lvlDir = modDir.plus_file("levels")
	var dir = Directory.new()
	
	if dir.dir_exists(modDir) and dir.dir_exists(lvlDir):
		if dir.open(lvlDir) != OK:
			print("Error loading PCK for levels")
		else:
			print("Loading PCK for levels")
		dir.list_dir_begin(true, true)
		while true:
			var currentFile: String = dir.get_next()
			
			if currentFile.empty():
				print("End of mods folder")
				break
			if currentFile.ends_with(".pck"):
				var fullName = dir.get_current_dir().plus_file(currentFile)
				printraw("Loading levels from: %s " % currentFile)
				if !ProjectSettings.load_resource_pack(fullName, false):
					print("(failed)")
				else:
					print("(success)")
	else:
		print("No mods folder")
		

func loadExtras():
	if !IsLevelsModsInitialized:
		initLevelsMods()
		
	var extras = []
	var dir = Directory.new()
	if dir.dir_exists("res://levels/extras"):
		if dir.open("res://levels/extras") == OK:
			dir.list_dir_begin()
			var file_name = dir.get_next()
			while file_name != "":
				if dir.current_is_dir() and file_name != "." and file_name != "..":
					extras.push_back(file_name)
				file_name = dir.get_next()
	else:
		print("No extras")
	return extras

