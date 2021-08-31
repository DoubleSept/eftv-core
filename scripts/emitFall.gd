extends Node

signal player_fall

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _on_player_player_fall():
	emit_signal("player_fall")

