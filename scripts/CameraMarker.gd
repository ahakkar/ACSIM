class_name CameraMarker
extends Sprite2D

var size_multiplier:float
var w_s:Vector2


# Draws a box represnting the camera view in minimap
func _draw():
	draw_rect(Rect2(-w_s.x/2, -w_s.y/2, w_s.x, w_s.y), Color.GREEN, false, -3.0)
	
	
# Rotates the box if camera is rotated
func _on_camera_zoom_2d_camera_rotation_changed(new_rotation):
	self.rotation = new_rotation


# Redraws the box to a different size if camera is zoomed
func _on_camera_zoom_2d_camera_zoom_changed(new_zoom_factor):
	w_s    = DisplayServer.window_get_size(0) / size_multiplier
	w_s.x /= new_zoom_factor
	w_s.y /= new_zoom_factor
	queue_redraw()
	

# Sets the initial size of the camera box, after game is loaded
func set_camera_marker() -> void:
	print("setting marker rdy")
	size_multiplier = Globals.map_size / 32
	w_s = DisplayServer.window_get_size(0) / size_multiplier


func set_camera_marker_position(pos:Vector2) -> void:
	print("marker pos: ", pos)
