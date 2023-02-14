# Class handles the camera zoom and movement in the game
class_name CameraZoom2D
extends Camera2D

var is_panning_camera = false
var tween

var camera_bounds:Array = [Vector2(0,0), Vector2(256*16, 256*16)]
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
	

func _ready() -> void:
	pass

	
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
	



