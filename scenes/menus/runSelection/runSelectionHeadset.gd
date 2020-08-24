extends "res://eftv-core/scripts/menus/ScriptMenu.gd"

func _ready():
	pass
		
func _on_run_changed(id, name, recordStr, hasPrevious, hasNext):
	$Title.text = name
	
	if recordStr == null:
		$Time.visible = false
	else:
		$Time.visible = true
		$Time.text = recordStr
