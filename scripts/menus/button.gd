extends MarginContainer

signal hover(node)
signal clicked(node)

func _ready():
	self.connect("mouse_entered", self, "_on_mouse_entered")
	self.connect("gui_input", self, "_on_gui_input")

func _on_mouse_entered():
	emit_signal("hover", self)
	
func _on_gui_input(event):
	if Input.is_action_just_pressed("leftclick"):
		emit_signal("clicked", self)