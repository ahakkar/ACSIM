class_name Game
extends Node2D

@onready var node_chunkhandler:ChunkHandler
@onready var node_mapbackground:MapBackground


func _ready() -> void:
	node_chunkhandler = find_child("ChunkHandler")
	node_mapbackground = find_child("MapBackground")
	
	
# sets the minimap texture as map background to avoid jarring transitions
func _on_minimap_set_map_background_texture(sprite, scaling:Vector2) -> void:
	self.set_map_background_texture(sprite, scaling)


func set_ready() -> void:
	node_chunkhandler.set_ready()
	
	
func set_map_background_texture(sprite, scaling:Vector2) -> void:
	node_mapbackground.set_map_background_texture(sprite, scaling)
