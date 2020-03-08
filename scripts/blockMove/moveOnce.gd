tool
extends "res://eftv-core/scripts/blockMove/basicMovable.gd"

const DEFAULT_COLOR = Color(0.5, 0.5, 0.5, 1.0)

func _ready():
	pass

func _on_release():
	print("Color:", mesh_color)
	self.set_mesh_color(mesh_color.linear_interpolate(DEFAULT_COLOR, 0.85))
	self.is_movable = false
