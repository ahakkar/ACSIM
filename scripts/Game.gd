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
	

func set_camera_position(pos:Vector2):
	node_camera.set_camera_position(pos)
	

func toggle_visibility():
	if self.visible:
		self.hide()
	else:
		self.show()
	
	if node_uilayer.visible:
		node_uilayer.hide()
	else:
		node_uilayer.show()
