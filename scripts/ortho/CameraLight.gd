extends "res://eftv-core/scripts/ortho/CameraOrtho.gd"

func _ready():
	._ready()

func _input(event):
	if event is InputEventMouseMotion:
		var position = self.project_position(event.position)
		$cursorLight.translation = self.to_local(position)
	._input(event)
