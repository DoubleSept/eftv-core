extends RichTextLabel

signal on_click

export var mainColorDefault: Color = Color("f7f4bc")
export var mainColorHover: Color = Color("FFFF4A")
export var backColorDefault: Color = Color("22000000")
export var backColorHover: Color = Color("dd000000")


const bbCodeBaseStart = "[center]"
const bbCodeBaseEnd = "[/center]"
const bbCodeHoverStart = "[wave amp=20 freq=5]"
const bbCodeHoverEnd = "[/wave]"

var is_on = false
var baseText
func _ready():
	baseText = text
	bbcode_enabled = true
	update()

func update():
	if is_on:
		bbcode_text = bbCodeBaseStart + bbCodeHoverStart + tr(baseText) + bbCodeHoverEnd + bbCodeBaseEnd
	else:
		bbcode_text = bbCodeBaseStart + tr(baseText) + bbCodeBaseEnd
	focus_mode
	set("custom_colors/default_color", mainColorHover if (is_on) else mainColorDefault)
	set("custom_colors/font_color_shadow", backColorHover if (is_on) else backColorDefault)

func _on_mouse_entered():
	is_on = true
	update()

func _on_mouse_exited():
	is_on = false
	update()

func _on_focus_entered():
	is_on = true
	update()

func _on_focus_exited():
	is_on = false
	update()

func _on_gui_input(event: InputEvent):
	if event.is_action_pressed("ui_accept"):
		emit_signal("on_click")
