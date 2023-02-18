class_name UILayer
extends CanvasLayer

@onready var node_minimap:Minimap
@onready var node_ui_control:UIControl
@onready var node_camera_marker:CameraMarker


func _ready() -> void:
	node_minimap = find_child("Minimap")
	node_camera_marker = find_child("CameraMarker")
	node_ui_control = find_child("UIControl")
	
	
func set_ready() -> void:
	node_minimap.set_ready()
	node_ui_control.set_ready()


func camera_rotation_changed(new_rotation):
	node_camera_marker.set_camera_marker_rotation(new_rotation)	


func camera_zoom_changed(new_zoom_factor):
	node_camera_marker.set_camera_marker_zoom(new_zoom_factor)	
	
