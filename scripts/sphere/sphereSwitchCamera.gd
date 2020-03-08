extends Area

export (String) var switch_to_camera = "CameraName"
var viewOrtho : Viewport

var switch_camera_node : Camera = null 

func _ready():
	var scene = get_tree().get_current_scene()
	viewOrtho = scene.find_node("viewportOrthogonal", true, false)

func _on_body_entered(body: Node):
	if switch_camera_node == null:
		switch_camera_node = viewOrtho.find_node(switch_to_camera, true, false)
	
	if(body.get_name() == "joueur"):
		var current_camera_node : Camera = viewOrtho.get_camera()
		
		if current_camera_node != switch_camera_node:
			# If not target we change and keep previous
			var previous_camera_node = current_camera_node
			switch_camera_node.current = true
			
			previous_camera_node.current = false
			previous_camera_node.hide_selecteur()