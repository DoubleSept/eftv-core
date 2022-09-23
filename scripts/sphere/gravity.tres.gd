extends Area

onready var triggered = false

func _ready():
	pass

func _on_body_entered(body: Node):
	if(body.get_name() == "player" and triggered == false):
		print_debug("SPHERE GRAVITY")
		PhysicsServer.area_set_param(
			$Area.get_rid(),
			PhysicsServer.AREA_PARAM_GRAVITY_VECTOR,
			Vector3.RIGHT)
		PhysicsServer.area_set_param(
			$Area.get_rid(),
			PhysicsServer.AREA_PARAM_GRAVITY,
			-10)
		Constants.CurrentGravity = Vector3.LEFT
		triggered = true
