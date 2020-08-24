extends Spatial

export (bool) var use_vr = true

onready var viewOrtho = self.find_node("viewportOrthogonal", true, false)
onready var viewPlayer = self.find_node("viewportPlayer", true, false)
onready var level = viewPlayer.find_node("sceneNode", true, false)

onready var noVR_camera : Camera = viewPlayer.find_node("NoVR_Camera", true, false)
onready var VR_camera : Camera = viewPlayer.find_node("Player_Camera", true, false)
onready var orthoCam: Node
onready var selecteur: Node

var SaveSystem
var current_level_resource : Resource

func _ready():
	viewOrtho.world = viewPlayer.world
	var VR = ARVRServer.find_interface("OpenVR")
	if use_vr and VR and VR.initialize():
		# VR MODE
		print("-- LAUNCHING IN VR --")
		get_node("viewportPlayer").arvr = true
		get_node("viewportPlayer").hdr = false
	else :
		print("-- LAUNCHING WITHOUT VR --")
	OS.vsync_enabled = false
	Engine.target_fps = 90
	
	SaveSystem = get_node("/root/SaveSystem")
	current_level_resource = SaveSystem.start_run()
	load_level()

func _on_sceneNode_level_finished():
	current_level_resource = SaveSystem.level_finished()
	if current_level_resource == null:
		get_tree().change_scene("res://eftv-core/scenes/menus/runEnd/endRunMain.tscn")
		return
	print("Next scene: "+current_level_resource.resource_path)
	load_level()

func load_level():
	viewPlayer.remove_child(level)
	viewOrtho.remove_child(orthoCam)
	
	level = current_level_resource.instance()
	level.set_name("sceneNode")
	level.connect("player_fall", self, "_on_sceneNode_player_fall")
	level.connect("level_finished", self, "_on_sceneNode_level_finished")
	viewPlayer.add_child(level)

	var player = viewPlayer.find_node("player", true, false)
	player.setUsingVR(use_vr)
	
	moveOrthogonalCameraToViewport()

func moveOrthogonalCameraToViewport():
	orthoCam = viewPlayer.find_node("orthogonalCamera", true, false)
	selecteur = orthoCam.find_node("selecteur", true, false)
	
	if orthoCam == null:
		print("OthogonalCamera node not found")
	else:
		print("OthogonalCamera node found")
	
	orthoCam.get_parent().remove_child(orthoCam)
	viewOrtho.add_child(orthoCam)
	
	if orthoCam is Camera:
		orthoCam.make_current()
	
	if not use_vr:
		noVR_camera = viewPlayer.find_node("NoVR_Camera", true, false)
		noVR_camera.make_current()
	else:
		VR_camera = viewPlayer.find_node("Player_Camera", true, false)
		VR_camera.make_current()
	
	selecteur.visible = false

func _on_sceneNode_player_fall():
	print("Restart Scene")
	load_level()
	if not use_vr:
		noVR_camera.current = true
	else:
		VR_camera.current = true
