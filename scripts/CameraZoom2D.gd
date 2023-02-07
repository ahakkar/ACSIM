# Class handles the camera zoom and movement in the game
class_name CameraZoom2D
extends Camera2D

var _zoom_level : float = 1.0 : set = _set_zoom_level
var is_dragging_camera = false
var tween

func _set_zoom_level(value: float) -> void:
	_zoom_level = clamp(value, Globals.CAMERA_MIN_ZOOM_LEVEL, Globals.CAMERA_MAX_ZOOM_LEVEL)		
	
	#interpolate frames between zoom levels to make zooming look smoother
	tween = get_tree().create_tween()
	tween.tween_property(
		self,
		"zoom",		
		Vector2(_zoom_level, _zoom_level),
		Globals.CAMERA_ZOOM_DURATION
	)

func _unhandled_input(event):
	# camera zooming
	if event.is_action_pressed("camera_zoom_in"):
		_set_zoom_level(_zoom_level - Globals.CAMERA_ZOOM_FACTOR)
	elif event.is_action_pressed("camera_zoom_out"):
		_set_zoom_level(_zoom_level + Globals.CAMERA_ZOOM_DURATION)
		
	# camera dragging		
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if !is_dragging_camera and event.pressed:
			is_dragging_camera = true
		if is_dragging_camera and !event.pressed:
			is_dragging_camera = false

	if event is InputEventMouseMotion and is_dragging_camera:
		if self.position != event.position:
			tween = get_tree().create_tween()
			tween.tween_property(self, "property", Vector2(self.position, event.position), Globals.CAMERA_ZOOM_DURATION)
		else:
			self.position = event.position * Globals.CAMERA_DRAG_MULTI
