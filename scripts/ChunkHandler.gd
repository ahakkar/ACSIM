class_name ChunkHandler
extends Node2D

# one tilemap is one chunk
# map consists of many chunks
# chunks are loaded to view when needed
# chunks are deleted after they are no longer needed (in view)

# This is done to speed up game loading and avoiding setting one large tilemap in one go
# which is extremely slow in godot 4.0, 4096x4096 takes minutes to fill with set_cell() commands

var chunks:Dictionary = {}
var unused_chunks:Dictionary = {}

func _ready():
	#thread = Thread.new()
	pass

#var map_tiles:Array[Array] = [[]]
#
#func start_handler() -> void:
#	# Initialize the map tile array with enough chunks to cover the whole map	
#	map_tiles.resize(Globals.map_size/Globals.CHUNK_SIZE)	
#	for y in map_tiles.size():
#		map_tiles[y].resize(Globals.map_size/Globals.CHUNK_SIZE)
#		for x in map_tiles.size():
#			map_tiles[y][x] = chunk.instantiate()
	
func add_chunk(x:int, y:int):
	var chunk = Chunk.new(x,y)
	self.add_child(chunk)
	
	chunk.generate_chunk()
	chunk.set_position(Vector2(x*Globals.CHUNK_SIZE,y*Globals.CHUNK_SIZE))
	chunk.set_visible(true)
	
	
		
	print("nodes in children: ", self.get_children()[0].get_used_cells(Globals.LAYER_TERRAIN).size())
	print("chunk visible in tree? : ", self.get_children()[0].is_visible_in_tree())
	print("handler visible? ", self.is_visible_in_tree())	
	
	#map_tiles[chunk_pos.y][chunk_pos.x].clear()
