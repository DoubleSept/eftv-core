extends Spatial

signal noHeadset

# Called when the node enters the scene tree for the first time.
func _ready():
	var VR = ARVRServer.find_interface("OpenVR")
	if VR and VR.initialize():
		# VR MODE
		get_viewport().arvr = true
		get_viewport().hdr = false
	else :
		emit_signal("noHeadset")
	OS.vsync_enabled = false
	Engine.target_fps = 90