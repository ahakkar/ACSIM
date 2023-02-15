# Class handles the camera zoom and movement in the game
class_name CameraZoom2D
extends Camera2D

signal camera_rotation_changed(new_rotation)
signal camera_zoom_changed(new_zoom_factor)

var is_panning_camera = false
var tween

var chunk_in_px:Vector2i = Vector2i(Globals.CHUNK_SIZE.x*Globals.TILE_SIZE_X, Globals.CHUNK_SIZE.y*Globals.TILE_SIZE_Y)
var game_res = DisplayServer.window_get_size(0)
var x_min_limit = self.game_res.x/2 - chunk_in_px.x


func _on_main_worldgen_ready() -> void:
	# set camera bounds to map size, with chunk_in_px room to go over	
	self.set_limit(SIDE_LEFT, -chunk_in_px.x)
	self.set_limit(SIDE_RIGHT, Globals.map_size*Globals.TILE_SIZE_X + chunk_in_px.x)
	self.set_limit(SIDE_TOP, -chunk_in_px.y)
	self.set_limit(SIDE_BOTTOM, Globals.map_size*Globals.TILE_SIZE_Y + chunk_in_px.y)	
	

func _on_set_camera_position(pos: Vector2) -> void:	
	self.position = pos	
	

func _process(_delta) -> void:		
	Globals.CAMERA_POSITION = self.position		
	
	while Input.is_action_pressed("camera_rotate_left_stepless"):
		rotate_camera(-0.1)
		await get_tree().create_timer(0.2).timeout
	while Input.is_action_pressed("camera_rotate_right_stepless"):
		rotate_camera(0.1)
		await get_tree().create_timer(0.2).timeout


func _ready() -> void:
	pass

	
func _set_camera_zoom_level(value: float) -> void:		
	# keep zoom level in bounds, return if zoom level was at min or max zoom
	var new_zoom_level = clamp(value, Globals.CAMERA_MIN_ZOOM_LEVEL, Globals.CAMERA_MAX_ZOOM_LEVEL)
	if new_zoom_level == Globals.CAMERA_ZOOM_LEVEL:
		return
		
	Globals.CAMERA_ZOOM_LEVEL = new_zoom_level
	
	#interpolate frames between zoom levels to make zooming look smoother
	tween = get_tree().create_tween()
	tween.tween_property(
		self,
		"zoom",		
		Vector2(Globals.CAMERA_ZOOM_LEVEL, Globals.CAMERA_ZOOM_LEVEL),
		Globals.CAMERA_ZOOM_DURATION
	)
	
	emit_signal("camera_zoom_changed", new_zoom_level)

	
func _unhandled_input(event):	
	if event.is_action_pressed("camera_zoom_in"):
		camera_zoom_in()
	if event.is_action_pressed("camera_zoom_out"):
		camera_zoom_out()
		
	if event.is_action_pressed("camera_rotate_left_fixed_step"):		
		rotate_camera(-45)
	if event.is_action_pressed("camera_rotate_right_fixed_step"):
		rotate_camera(45)		
	if event.is_action_pressed("camera_reset_rotation"):
		reset_camera_rotation()
		
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:		
		if !is_panning_camera and event.pressed:
			is_panning_camera = true
		if is_panning_camera and !event.pressed:
			is_panning_camera = false

	if event is InputEventMouseMotion and is_panning_camera:
		# rotate event.relative vector with camera rotation so camera moves to "correct" direction
		self.position -= event.relative.rotated(self.rotation) * Globals.CAMERA_PAN_MULTI
		
		# prevent camera from going overboard
		self.position.x = clamp(
			self.position.x,
			x_min_limit, 
			Globals.map_size*Globals.TILE_SIZE_X - chunk_in_px.x
			);
		self.position.y = clamp(
			self.position.y,
			0,
			Globals.map_size*Globals.TILE_SIZE_Y
			);
			

func camera_zoom_in() -> void:	
	_set_camera_zoom_level(Globals.CAMERA_ZOOM_LEVEL - Globals.CAMERA_ZOOM_FACTOR)
	

func camera_zoom_out() -> void:
	_set_camera_zoom_level(Globals.CAMERA_ZOOM_LEVEL + Globals.CAMERA_ZOOM_DURATION)
	
	
func get_camera_position():
	return self.position
	

func reset_camera_rotation() -> void:
	self.rotation_degrees = 0
	emit_signal("camera_rotation_changed", self.rotation)
	
func rotate_camera(step:float) -> void:
	self.rotation_degrees += step
	emit_signal("camera_rotation_changed", self.rotation)


