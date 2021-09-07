extends Spatial

signal noHeadset

# Called when the node enters the scene tree for the first time.
func _ready():
	var VR = ARVRServer.find_interface("OpenVR")
	if VR and VR.initialize():
		# VR MODE
		print("ARVR Enabled")
		get_viewport().arvr = true
		get_viewport().hdr = false
	else :
		emit_signal("noHeadset")
	OS.vsync_enabled = false
	Engine.target_fps = 90


func _on_newTranslation():
	$Label3D.set_text(tr("TEXT_OTHER_MENU"))
	var choosePanel = get_tree().get_root().find_node("ChooseMovement", true, false)
	choosePanel.updateWindow()
