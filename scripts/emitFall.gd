extends Node

signal player_fall

func _ready():
	# Scene cannot be launched alone
	if get_tree().get_current_scene().get_name() != "GameMain":
		var filename = get_tree().current_scene.filename
		print("Launched: %s" % [filename])
		LevelSystem.TEST_LEVEL = filename
		get_tree().change_scene(Constants.SCENE_MAIN)

func _on_player_player_fall():
	emit_signal("player_fall")
