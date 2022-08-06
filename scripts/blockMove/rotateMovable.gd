tool
extends "basicMovable.gd"

func _ready():
	pass

func move(speedSent):
	if not Engine.editor_hint:
		if player.collides_with(self):
			if not sound_playing:
				sound_playing = true
				$denySound.play()
			return

		var speed = speedSent/3000.0
		print(speed)
		if Input.is_action_pressed("move_left"):
			rotate_z(speed)
		if Input.is_action_pressed("move_right"):
			rotate_z(-speed)
		if Input.is_action_pressed("move_forward"):
			rotate_x(-speed)
		if Input.is_action_pressed("move_backwards"):
			rotate_x(speed)


