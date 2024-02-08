extends Area

export (String) var switch_to_camera = "CameraName"
var viewOrtho : Viewport
export var is_visible_ortho = true setget set_visible_ortho

var switch_camera_node : Camera = null

func _ready():
	var scene = get_tree().get_current_scene()
	viewOrtho = scene.find_node("viewportOrthogonal", true, false)

func _on_body_entered(body: Node):
	if switch_camera_node == null:
		switch_camera_node = viewOrtho.find_node(switch_to_camera, true, false)

	if(body.get_name() == "player"):
		var current_camera_node : Camera = viewOrtho.get_camera()

		if current_camera_node != switch_camera_node:
			# If not target we change and keep previous
			var previous_camera_node = current_camera_node
			switch_camera_node.current = true

			previous_camera_node.current = false
			previous_camera_node.hide_selecteur()

func set_visible_ortho(new_visible):
	is_visible_ortho = new_visible
	$meshOuter.set_layer_mask_bit(1, new_visible)
	$meshInner.set_layer_mask_bit(1, new_visible)
