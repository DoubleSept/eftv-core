extends "res://eftv-core/scripts/menus/ScriptMenu.gd"

func _ready():
	pass
		
func _on_run_changed(id, name, recordStr):
	$Spatial/Title.text = name
	
	if recordStr == null:
		$Spatial/Time.visible = false
	else:
		$Spatial/Time.visible = true
		$Spatial/Time.text = recordStr
