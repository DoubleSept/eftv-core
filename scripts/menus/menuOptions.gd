extends VBoxContainer

signal switchMenu(newMenu)

onready var optionSelected = $bt_Continue
onready var lastOption = get_child_count() - 1

const COLOR_SELECTED : Color = Color("ffffffff")
const COLOR_UNSELECTED : Color = Color("7fffffff")

func _ready():
	for optionNode in self.get_children():
		optionNode.connect("hover", self, "update_buttons")
	set_process_input(true)

func _input(event : InputEvent):
	if event.is_action_pressed("ui_down"):
		var currentIndex = optionSelected.get_index()
		var nextIndex = 0 if currentIndex == lastOption else currentIndex+1
		update_buttons(self.get_child(nextIndex))
	elif event.is_action_pressed("ui_up"):
		var currentIndex = optionSelected.get_index()
		var nextIndex = lastOption if currentIndex == 0 else currentIndex-1
		update_buttons(self.get_child(nextIndex))
	elif (event.is_action_pressed("ui_accept")):
		print("OK ", optionSelected.get_index(), optionSelected, optionSelected.name)
		# Activate a button
		if optionSelected.get_index() == 0:
			optionContinue()
		elif optionSelected.get_index() == 1:
			print("New game")
		elif optionSelected.get_index() == 2:
			optionChooseLevel()
		elif optionSelected.get_index() == 3:
			print("About")
		elif optionSelected.get_index() == 4:
			get_tree().quit()

func optionContinue():
	emit_signal("switchMenu", "loading")
	var t = Timer.new()
	t.set_wait_time(0.1)
	t.set_one_shot(true)
	self.add_child(t)
	t.start()
	yield(t, "timeout")
	get_tree().change_scene("res://eftv-core/scenes/main-vr.tscn")
	
func optionChooseLevel():
	get_tree().set_input_as_handled()
	emit_signal("switchMenu", "levelsMenu")

func update_buttons(node):
	for optionNode in self.get_children():
		if optionNode == node:
			optionNode.get_child(0).set("custom_colors/font_color", COLOR_SELECTED)
		else:
			optionNode.get_child(0).set("custom_colors/font_color", COLOR_UNSELECTED)
	optionSelected = node
