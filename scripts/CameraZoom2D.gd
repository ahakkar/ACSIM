# Class handles the camera zoom and movement in the game
class_name CameraZoom2D
extends Camera2D

var is_panning_camera = false
var tween

func _set_camera_zoom_level(value: float) -> void:
	Globals.CAMERA_ZOOM_LEVEL = clamp(value, Globals.CAMERA_MIN_ZOOM_LEVEL, Globals.CAMERA_MAX_ZOOM_LEVEL)		
	
	#interpolate frames between zoom levels to make zooming look smoother
	tween = get_tree().create_tween()
	tween.tween_property(
		self,
		"zoom",		
		Vector2(Globals.CAMERA_ZOOM_LEVEL, Globals.CAMERA_ZOOM_LEVEL),
		Globals.CAMERA_ZOOM_DURATION
	)
	
func camera_zoom_in() -> void:	
	_set_camera_zoom_level(Globals.CAMERA_ZOOM_LEVEL - Globals.CAMERA_ZOOM_FACTOR)		

func camera_zoom_out() -> void:
	_set_camera_zoom_level(Globals.CAMERA_ZOOM_LEVEL + Globals.CAMERA_ZOOM_DURATION)
		

func _unhandled_input(event):	
	if event.is_action_pressed("camera_zoom_in"):
		camera_zoom_in()
	if event.is_action_pressed("camera_zoom_out"):
		camera_zoom_out()
	
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if !is_panning_camera and event.pressed:
			is_panning_camera = true
		if is_panning_camera and !event.pressed:
			is_panning_camera = false

	if event is InputEventMouseMotion and is_panning_camera:
		self.position -= event.relative * Globals.CAMERA_PAN_MULTI
	
