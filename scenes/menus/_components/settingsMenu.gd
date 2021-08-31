extends PanelContainer

signal basemenu

onready var locales = TranslationServer.get_loaded_locales()

func _ready():
	pass

func _on_lang_switch():
	var current_locale = TranslationServer.get_locale()
	print("Locales: %s (current: %s)" % [locales, current_locale])
	# Get current index
	var currentIdx = 0
	for i in range(len(locales)):
		if locales[i] == current_locale:
			currentIdx = i
			
	currentIdx = (currentIdx+1) % len(locales)
	TranslationServer.set_locale(locales[currentIdx])


func _on_back():
	emit_signal("basemenu")
