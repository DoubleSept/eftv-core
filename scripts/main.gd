extends Spatial

export (bool) var use_vr = true

onready var viewOrtho = self.find_node("viewportOrthogonal", true, false)
onready var viewPlayer = self.find_node("viewportPlayer", true, false)
onready var level = viewPlayer.find_node("sceneNode", true, false)

onready var noVR_camera : Camera = viewPlayer.find_node("NoVR_Camera", true, false)
onready var VR_camera : Camera = viewPlayer.find_node("Player_Camera", true, false)
onready var orthoCam: Node
onready var selecteur: Node

onready var onScreenHolder= $vc/GameMapContainer/OptionalOnScreenHolder

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
	
	if(level==null):
		print_debug("Null level at start")
	
	current_level_resource = SaveSystem.start_run()
	load_level(current_level_resource)

func _on_sceneNode_level_finished():
	print_debug("\n\nENDING LEVEL %s" % [current_level_resource.resource_path])
	var next_level_resource = SaveSystem.level_finished()
	if next_level_resource == null:
		print_debug("End Run")
		var _changed = get_tree().change_scene(Constants.SCENE_MENU_END_RUN)
		return
	else:
		print_debug("Loading next scene: %s" % [next_level_resource.resource_path])
	
	call_deferred("load_level", next_level_resource)

func load_level(level_resource):
	var old_path = current_level_resource.resource_path  if (current_level_resource != null) else "No previous path"
	
	if(level != null):
		viewPlayer.remove_child(level)
	else:
		print_debug("WARN: No level node (%s)" % [old_path])
	
	if(orthoCam != null):
		viewOrtho.remove_child(orthoCam)
	else:
		print_debug("WARN: No OrthoCam node (%s)" % [old_path])
	
	print_debug("Level loading 2/4 (%s): Load new" % [old_path])
	current_level_resource = level_resource
	level = current_level_resource.instance()
	level.set_name("sceneNode")
	level.connect("player_fall", self, "_on_sceneNode_player_fall")
	viewPlayer.add_child(level)
	
	for obj in onScreenHolder.get_children():
		onScreenHolder.remove_child(obj)
	
	if level.has_node("OnScreenContainer"):
		var onScreenContainer = level.get_node("OnScreenContainer")
		level.remove_child(onScreenContainer)
		onScreenHolder.add_child(onScreenContainer)
	
	print_debug("Level loading 3/4 (%s): Player and Camera" % [current_level_resource.resource_path])

	var player = viewPlayer.find_node("player", true, false)
	player.set_using_vr(use_vr)
	
	moveOrthogonalCameraToViewport()
	print_debug("Level loading 4/4 (%s): LOADED" % [current_level_resource.resource_path])

func moveOrthogonalCameraToViewport():
	orthoCam = viewPlayer.find_node("orthogonalCamera", true, false)
	selecteur = orthoCam.find_node("selecteur", true, false)
	
	if orthoCam == null:
		print_debug("\tOrthogonalCamera node not found")
	else:
		print_debug("\tOrthogonalCamera node found")
	
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
	print_debug("Scene restart")
	load_level(current_level_resource)
	if not use_vr:
		noVR_camera.current = true
	else:
		VR_camera.current = true
