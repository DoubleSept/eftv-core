extends "res://eftv-core/scripts/blockMove/basicMovable.gd"

## UNUSED

export (Vector3) var end_position = Vector3(0,0,0)
export (float) var duration = 30

var start_position : Vector3
var move_vector
var currentTime = 0.0
var currentTimeFromStart = 0.0
var direction : bool = true

func _ready():
	start_position = self.translation
	move_vector = (end_position) - (start_position)
	set_process(true)

func _process(delta):
	currentTime += delta
	
	if !self.hovered:
		return
	
	if direction:
		currentTimeFromStart += delta
	else:
		currentTimeFromStart -= delta
	var completionPercent = currentTimeFromStart / duration
	
	if completionPercent >= 0 and completionPercent <= 1:
		self.translation = start_position + (completionPercent * move_vector)
	else:
		direction = !direction

