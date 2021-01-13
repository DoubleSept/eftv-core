extends MarginContainer

# Called when the node enters the scene tree for the first time.
func _ready():
	$recordBox/recordInside/Vbox/Title.text = SaveSystem.runInfos.name
	var durationMs = SaveSystem.runDurationMs
	var minutes = durationMs / 60000
	var seconds = (durationMs / 1000) - (60*minutes)
	$recordBox/recordInside/Vbox/Time.text = "%02d:%02d" % [minutes, seconds]
	
	
	var id = SaveSystem.runInfos.id
	# Background
	var directory = Directory.new();
	var previewPath = LevelSystem.LEVELS_ROOT+id+"/preview.png"
	if directory.file_exists(previewPath):
		$Preview.texture = load(previewPath)
	else:
		$Preview.texture = load(LevelSystem.LEVELS_ROOT+"defaultPreview.png")
	
	# Check if new record
	var records = SaveSystem.gameData[SaveSystem.KEY_LEVELS_INFOS_MS]
	if (not id in records) or (durationMs < records[id]):
		$recordBox/recordInside/Vbox/Record.visible = true
	
	# Has next run?
	if not SaveSystem.runInfos.hasNextRun:
		$footer/footerSplitter/nextRun.visible = false
		$footer/footerSplitter/backToMenu.size_flags_horizontal = SIZE_EXPAND_FILL
	SaveSystem.run_finished()

func _on_backToMenu_pressed():
	get_tree().change_scene("res://eftv-core/scenes/menus/menuMain.tscn")

func _on_nextRun_pressed():
	get_tree().change_scene("res://eftv-core/scenes/main-vr.tscn")
