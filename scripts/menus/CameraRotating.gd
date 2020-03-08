extends Camera

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _process(delta):
	self.rotate_y(delta*0.02)
