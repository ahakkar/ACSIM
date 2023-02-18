# Class handles the camera zoom and movement in the game
class_name Camera
extends Camera2D

signal camera_rotation_changed(new_rotation)
signal camera_zoom_changed(new_zoom_factor)

var is_panning_camera:bool = false
var tween:Tween

var chunk_in_px:Vector2i = Vector2i(
	Globals.CHUNK_SIZE.x * Globals.TILE_SIZE_X, 
	Globals.CHUNK_SIZE.y * Globals.TILE_SIZE_Y)
var game_res:Vector2i = DisplayServer.window_get_size(0)
var x_min_limit:int = self.game_res.x/2 - chunk_in_px.x


func _process(_delta) -> void:
	Globals.CAMERA_POSITION = self.get_camera_position()	


func get_camera_position():
	return self.position
	

func get_camera_panning() -> bool:
	return self.is_panning_camera
	

func get_camera_rotation():
	return self.rotation
	

func set_camera_panning(value:bool) -> void:
	self.is_panning_camera = value
	

func set_camera_position(pos: Vector2) -> void:		
	self.position = pos	
	print("camera pos set:", self.position)	


func set_camera_limits() -> void:
	if Globals.map_size < Globals.MAP_MIN_WIDTH:
		push_error("Camera: implausible map size '" + str(Globals.map_size) + "' while setting camera limits:")
		
	# set camera bounds to map size, with chunk_in_px room to go over	
	self.set_limit(SIDE_LEFT, -chunk_in_px.x)
	self.set_limit(SIDE_RIGHT, Globals.map_size*Globals.TILE_SIZE_X + chunk_in_px.x)
	self.set_limit(SIDE_TOP, -chunk_in_px.y)
	self.set_limit(SIDE_BOTTOM, Globals.map_size*Globals.TILE_SIZE_Y + chunk_in_px.y)	


func set_camera_zoom_level(value: float) -> void:		
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
	

func clamp_camera_position() -> void:	
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
			

func camera_pan_position(value) -> void:	
	self.position -= value


func camera_zoom_in() -> void:	
	set_camera_zoom_level(Globals.CAMERA_ZOOM_LEVEL + Globals.CAMERA_ZOOM_FACTOR)
	

func camera_zoom_out() -> void:
	set_camera_zoom_level(Globals.CAMERA_ZOOM_LEVEL - Globals.CAMERA_ZOOM_DURATION)
	

func camera_reset_rotation() -> void:
	self.rotation_degrees = 0
	emit_signal("camera_rotation_changed", self.rotation)
	
	
func camera_rotate(step:float) -> void:
	self.rotation_degrees += step
	emit_signal("camera_rotation_changed", self.rotation)
	
		
func camera_take_screenshot() -> void:	
	# Saves screenshot to user://
	# Windows: %APPDATA%\Godot\app_userdata\[project_name]
	# macOS: ~/Library/Application Support/Godot/app_userdata/[project_name]
	# Linux: ~/.local/share/godot/app_userdata/[project_name]
	
	var user_path:String = "user://screenshots/"
	var moment:Dictionary = Time.get_datetime_dict_from_system()
	var time:String = "%s-%s-%s_%s_%s-%s" % [
		moment.get("year"),
		moment.get("month"),
		moment.get("day"),
		moment.get("hour"),
		moment.get("minute"),
		moment.get("second")
		]
	var path:String = user_path + "acsim_" + time + ".png"	
	var captured_image:Image = get_viewport().get_texture().get_image()	

	captured_image.save_png(path)
	
		


