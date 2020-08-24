extends MarginContainer

signal previousButton
signal nextButton

var SaveSystem
var currentId = null
# Called when the node enters the scene tree for the first time.
func _ready():
	SaveSystem = get_node("/root/SaveSystem")
	
	$recordBox/recordInside/Vbox/Title.text = "Loading"
	$recordBox/recordInside/Vbox/Time.text = "00:00"

func _on_backToMenu_pressed():
	get_tree().change_scene("res://eftv-core/scenes/menus/menuMain.tscn")
	
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

func _on_GoNext_pressed():
	emit_signal("nextButton")

func _on_Start_pressed():
	SaveSystem.gameData[SaveSystem.KEY_CURRENT_LEVEL] = currentId
	get_tree().change_scene("res://eftv-core/scenes/main-vr.tscn")

func _on_GoBack_pressed():
	emit_signal("previousButton")
