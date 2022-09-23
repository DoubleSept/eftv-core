tool
extends BasicMovable

const DEFAULT_COLOR = Color(0.5, 0.5, 0.5, 1.0)

func _ready():
	pass

func _on_release():
	._on_release()
	self.set_mesh_color(mesh_color.linear_interpolate(DEFAULT_COLOR, 0.85))
	self.is_movable = false
