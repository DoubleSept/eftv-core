extends MarginContainer

func _ready():
	pass

func _on_continue_pressed():
	get_tree().change_scene("res://eftv-core/scenes/menus/menuMain.tscn")

func _on_Exit_pressed():
	get_tree().quit()
