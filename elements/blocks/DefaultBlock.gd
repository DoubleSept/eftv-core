extends BasicMovable
class_name DefaultBlock

signal newTarget(target)

func _physics_process(delta):
	pass
	
func move(newTargetPosition: Vector3, cancelAxisX = false, cancelAxisY = false, cancelAxisZ = false):
	emit_signal("newTarget", newTargetPosition)
