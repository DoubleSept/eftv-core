extends Node
class_name RunInfos

export(String) var id = "DEFAULT"
export(int) var index = -1
export(String) var title = "DEFAULT"
export(bool) var hasNextRun = false
export(Array) var levels = []
export(bool) var secretFound = false
export(bool) var isSecret = false

func _ready():
	pass # Replace with function body.
