class_name Game
extends Node2D

@onready var node_camera:CameraZoom2D
@onready var node_chunkhandler:ChunkHandler
@onready var node_minimap:Minimap
@onready var node_mapbackground:MapBackground
@onready var node_uilayer


func _ready() -> void:
	node_camera = find_child("CameraZoom2D")
	node_chunkhandler = find_child("ChunkHandler")
	node_minimap = find_child("Minimap")
	node_mapbackground = find_child("MapBackground")
	node_uilayer = find_child("UILayer")
	
	
# sets the minimap texture as map background to avoid jarring transitions
func _on_minimap_set_map_background_texture(sprite, scaling:Vector2) -> void:
	self.set_map_background_texture(sprite, scaling)


func set_ready() -> void:
	node_camera.set_ready()
	node_chunkhandler.set_ready()
	node_minimap.set_ready()
	
	
func set_map_background_texture(sprite, scaling:Vector2) -> void:
	node_mapbackground.set_map_background_texture(sprite, scaling)
	

func camera_clamp_position() -> void:
	node_camera.clamp_camera_position()
	

func camera_pan_position(value):
	node_camera.camera_pan_position(value)
	

func camera_zoom_out() -> void:
	node_camera.camera_zoom_out()
		

func camera_zoom_in() -> void:
	node_camera.camera_zoom_in()
		

func camera_rotate(value) -> void:
	node_camera.camera_rotate(value)
	
		
func camera_reset_rotation() -> void:
	node_camera.camera_reset_rotation()


func camera_get_panning() -> bool:
	return node_camera.get_camera_panning()
	

func camera_get_rotation():
	return node_camera.get_camera_rotation()	
	
	
func camera_set_panning(value:bool) -> void:
	node_camera.set_camera_panning(value)
	

func camera_set_position(pos:Vector2) -> void:
	node_camera.set_camera_position(pos)
	

func camera_take_screenshot() -> void:
	node_camera.camera_take_screenshot()		
	

func toggle_visibility() -> void:
	if self.visible:
		self.hide()
	else:
		self.show()
	
	if node_uilayer.visible:
		node_uilayer.hide()
	else:
		node_uilayer.show()
