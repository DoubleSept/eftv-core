extends Camera

var STANDARD_SPEED=50
var PRECISE_SPEED=10

var to = Vector3(0,0,0)
var from = Vector3(0,0,0)

var currentSelected : Node = null
var selecteur : MeshInstance = null
var selecteurMaterial : Material = null

var mouse_pressed = false
var mouse_position = Vector2(0,0)

var debugSelecteur = false

var oldPosition3D : Vector3

func checkHover(event):
	from = self.project_ray_origin(event.position)
	to = from + self.project_ray_normal(event.position)*10000
	var ds = PhysicsServer.space_get_direct_state(get_world().get_space())
	var col = ds.intersect_ray(from, to)
	if("collider" in col.keys()):
		var obj = col["collider"]
		if not "is_movable" in obj or not obj.is_movable:
			#Not a selectable
			return
			
		var colpos = col["position"]/2
		var _blockpos = Vector3(ceil(colpos[0]), ceil(colpos[1]), 0)
		
		if obj != currentSelected:
			obj._hovered()
			changeSelection(obj)
	else:
		if currentSelected != null:
			currentSelected._unhovered()
		currentSelected = null
		selecteur.visible = false

func changeSelection(obj):
	currentSelected = obj
	print("New selected: ", currentSelected.name)
	
	# Manage selector
	# Set visible
	selecteur.visible = true
	# Set shape
	var meshNode : MeshInstance = currentSelected.find_node("mesh", false)
	selecteur.set_mesh( meshNode.get_mesh().create_outline(0.1) )

	# Set material
	for i in range( selecteur.get_surface_material_count() ):
		selecteur.set_surface_material(i, selecteurMaterial)
	selecteur.global_transform = currentSelected.global_transform

func dragNdrop(position: Vector2):
	var newPosition3D = self.project_ray_origin(position)
	
	var moveVector = newPosition3D - oldPosition3D
	if Input.is_action_pressed("improved_precision"):
		moveVector /= 2
	currentSelected.move(moveVector)
	selecteur.global_transform = currentSelected.global_transform
	
	oldPosition3D = newPosition3D
	
func release():
	selecteur.visible = false
	currentSelected._on_release()
	currentSelected = null

func _input(event):
	if self.current == false:
		return
	
	if event is InputEventMouse:
		mouse_position = event.position
	
	# Check if mouse button is pressed
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
		mouse_pressed = event.pressed
		# Save position
		oldPosition3D = self.project_ray_origin(mouse_position)
		if not mouse_pressed and currentSelected != null:
			# When mouse released call correct function
			release()
	
	if not mouse_pressed and event is InputEventMouseMotion:
		# Mouse is moving without click, selection may change
		checkHover(event)
		
	if mouse_pressed and event is InputEventMouseMotion and currentSelected != null:
		# Drag N drop
		dragNdrop(mouse_position)
	
	# Keyboard
	if(event.is_action_pressed("ui_cancel")):
		get_tree().set_input_as_handled()
		var _changed = get_tree().change_scene(Constants.SCENE_MENU_MAIN)

func hide_selecteur():
	selecteur.visible = false
	currentSelected = null

func _ready():
	selecteur = get_node("selecteur")
	selecteur.visible = false
	if(selecteur.get_surface_material_count() != 1):
		print("Selector has more than one surface material")
		get_tree().quit()
	selecteurMaterial = selecteur.get_surface_material(0)
