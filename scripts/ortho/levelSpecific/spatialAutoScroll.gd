extends "res://eftv-core/scripts/ortho/CameraOrtho.gd"

export (Vector3) var end_position = Vector3(0,0,0)
export (float) var delay_start_sec = 2
export (float) var duration = 30

var offset_translation
var move_vector
var currentTime = 0.0
var currentTimeFromStart = 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	offset_translation = self.translation
	move_vector = (end_position) - (offset_translation)
	set_process(true)

func _process(delta):
	currentTime += delta

	if currentTime < delay_start_sec:
		return

	currentTimeFromStart += delta
	var completionPercent = currentTimeFromStart / duration

	if completionPercent <= 1:
		if currentSelected != null:
			selecteur.global_transform = currentSelected.global_transform

		# Do translate
		self.translation = offset_translation + (completionPercent * move_vector)

		# Move selected
		if mouse_pressed and currentSelected != null:
			dragNdrop(mouse_position)
