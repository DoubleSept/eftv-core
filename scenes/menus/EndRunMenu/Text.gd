extends MarginContainer

# Called when the node enters the scene tree for the first time.
func _ready():

	# Check if demo
	if LevelSystem.IsDemoMode:
		$footer/footerSplitter/nextRun.text = tr("TEXT_RETRY")

	# Infos box
	var durationMs = 60
	var id = "00-demo"
	if SaveSystem.runInfos:
		$recordBox/recordInside/Vbox/Title.text = SaveSystem.runInfos.name
		durationMs = SaveSystem.runDurationMs
		id = SaveSystem.runInfos.id

		# Has next run?
		if not SaveSystem.runInfos.hasNextRun:
			$footer/footerSplitter/nextRun.visible = false
			$footer/footerSplitter/backToMenu.size_flags_horizontal = SIZE_EXPAND_FILL
		SaveSystem.run_finished()

		if SaveSystem.runInfos.isSecret:
			$recordBox/ExternRect.color.s = 1.0

		$recordBox/recordInside/Vbox/Secret.visible = SaveSystem.runInfos.secretFound

	var minutes = durationMs / 60000
	var seconds = (durationMs / 1000) - (60*minutes)
	$recordBox/recordInside/Vbox/Time.text = "%02d:%02d" % [minutes, seconds]

	# Background
	var directory = Directory.new();
	var previewPath = LevelSystem.LEVELS_ROOT+id+"/preview.png"
	if directory.file_exists(previewPath):
		$Preview.texture = load(previewPath)
	else:
		$Preview.texture = load(LevelSystem.LEVELS_ROOT+"defaultPreview.png")

	# Check if new record
	var records = SaveSystem.gameData[SaveSystem.KEY_LEVELS_INFOS_MS]
	if (not id in records) or (records[id] == null) or (durationMs < records[id]):
		$recordBox/recordInside/Vbox/Record.visible = true

func _on_backToMenu_pressed():
	get_tree().change_scene(Constants.SCENE_MENU_MAIN)

func _on_nextRun_pressed():
	SaveSystem.start_run()
	get_tree().change_scene(Constants.SCENE_MAIN)

func _on_Secret_pressed():
	SaveSystem.start_run(SaveSystem.runInfos.id, true)
	get_tree().change_scene(Constants.SCENE_MAIN)
