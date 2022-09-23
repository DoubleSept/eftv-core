extends Area

onready var triggered = false

func _ready():
	pass

func _on_body_entered(body: Node):
	if(body.get_name() == "player" and triggered == false):
		triggered = true
		get_tree().get_current_scene()._on_secret_found()
		SaveSystem.secret_found()
		$AnimationPlayer.play("SphereDisappear")


func _on_animation_finished(anim_name):
	if anim_name == "SphereDisappear":
		queue_free()
