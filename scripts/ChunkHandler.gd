class_name ChunkHandler
extends Node2D

# one tilemap is one chunk
# map consists of many chunks
# chunks are loaded to view when needed
# chunks are deleted after they are no longer needed (in view)

# This is done to speed up game loading and avoiding setting one large tilemap in one go
# which is extremely slow in godot 4.0, 4096x4096 takes minutes to fill with set_cell() commands

var map_tiles:Array[Array] = [[]]
var chunks:Dictionary = {}
var unused_chunks:Dictionary = {}

func _init() -> void:
	self.name = "ChunkHandler"

func _ready():
	#thread = Thread.new()
	pass



func start_handler() -> void:
	# Initialize the map tile array with enough chunks to cover the whole map	
	map_tiles.resize(Globals.map_size/Globals.CHUNK_SIZE)	
	for y in map_tiles.size():
		map_tiles[y].resize(Globals.map_size/Globals.CHUNK_SIZE)		
	
func add_chunk(x:int, y:int):	
	var chunk = Chunk.new(x,y)
	
	var start = Time.get_ticks_usec()	
	chunk.generate_chunk()	
	self.add_child(chunk)
	var end = Time.get_ticks_usec()
	print("generate a chunk ", (end-start)/1000.0, "ms")	
	
	
	#chunk.set_position(Vector2(x*Globals.CHUNK_SIZE,y*Globals.CHUNK_SIZE))

	
	#map_tiles[chunk_pos.y][chunk_pos.x].clear()
