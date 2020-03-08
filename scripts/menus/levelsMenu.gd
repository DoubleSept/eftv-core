tool
extends VBoxContainer

signal switchMenu(newMenu)

var maxLevelIndex = 0
var currentSection

var tileScene = load("res://eftv-core/scenes/menus/components/tile.tscn")

const COLOR_SELECTED : Color = Color("ffffffff")
const COLOR_UNSELECTED : Color = Color("7fffffff")

var currentSelected : Label

# Called when the node enters the scene tree for the first time.
func _ready():
	if SaveSystem.KEY_MAX_LEVEL_FINISHED in SaveSystem.gameData:
		var maxLevel = SaveSystem.gameData[SaveSystem.KEY_MAX_LEVEL_FINISHED]
		maxLevelIndex = LevelSystem.get_index_from_string(maxLevel)
	
	# Make correct headers visible
	if maxLevelIndex > 19:
		$"header/sections/section2".visible = true
	if maxLevelIndex > 39:
		$"header/sections/section3".visible = true
		
	currentSection = $"header/sections/section1"
	
	generateGrid()
	switchSection(0)

func generateGrid():
	for section in [0,1,2]:
		# Generate first section
		for i in range(20 * section, min(maxLevelIndex+1, 20 * section + 20)):
			#New tile
			var tile = tileScene.instance()
			tile.name = LevelSystem.LEVELS_LIST[i][0]
			
			# Change label text
			tile.get_child(0).text = "%02d" % (i+1)
			tile.connect("hover", self, "_on_hover_level")
			tile.connect("clicked", self, "_on_click_level")
			
			$levels.get_child(section).add_child(tile)

func switchSection(sectionNb : int):
	for section in [0,1,2]:
		$levels.get_child(section).visible = (section == sectionNb)

func updateSelected(newSelected):
	if currentSelected != null:
		currentSelected.set("custom_colors/font_color", COLOR_UNSELECTED)
	currentSelected = newSelected
	currentSelected.set("custom_colors/font_color", COLOR_SELECTED)
	

func _on_hover_level(level):
	updateSelected(level.get_child(0))
	
func _on_click_level(level):
	SaveSystem.gameData[SaveSystem.KEY_CURRENT_LEVEL] = level.name
	emit_signal("switchMenu", "loading")
	var t = Timer.new()
	t.set_wait_time(0.1)
	t.set_one_shot(true)
	self.add_child(t)
	t.start()
	yield(t, "timeout")
	get_tree().change_scene("res://eftv-core/scenes/main-vr.tscn")

func _on_back_gui_input(event):
	updateSelected($back/text)
	if Input.is_action_just_pressed("leftclick"):
		get_tree().set_input_as_handled()
		print("Click")
		emit_signal("switchMenu", "options")

func _on_section1_gui_input(event):
	updateSelected($header/sections/section1/text)
	if Input.is_action_just_pressed("leftclick"):
		switchSection(0)

func _on_section2_gui_input(event):
	updateSelected($header/sections/section2/text)
	if Input.is_action_just_pressed("leftclick"):
		switchSection(1)

func _on_section3_gui_input(event):
	updateSelected($header/sections/section3/text)
	if Input.is_action_just_pressed("leftclick"):
		switchSection(2)
