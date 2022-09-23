extends "res://eftv-core/scripts/menus/ScriptMenu.gd"

func _ready():
	pass

func _on_run_changed(_id, name, recordStr):
	$Spatial/Title.mesh.text = name

	if recordStr == null:
		$Spatial/Time.visible = false
	else:
		$Spatial/Time.visible = true
		$Spatial/Time.mesh.text = recordStr
