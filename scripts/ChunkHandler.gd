class_name ChunkHandler
extends Node2D

# one tilemap is one chunk
# map consists of many chunks
# chunks are loaded to view when needed
# chunks are deleted after they are no longer needed (in view)

# This is done to speed up game loading and avoiding setting one large tilemap in one go
# which is extremely slow in godot 4.0, 4096x4096 takes minutes to fill with set_cell() commands

var chunks:Dictionary = {}
var unready_chunks:Dictionary = {}
var window_width = DisplayServer.window_get_size(0).x
var distance = abs((window_width/(Globals.CHUNK_SIZE.x*Globals.TILE_SIZE_X)) / 2 +1 )


func _init() -> void:
	self.name = "ChunkHandler"
	
	
func _process(_delta):
	update_chunks()
	clean_up_chunks()
	reset_chunks()
	

func _ready():
	#thread = Thread.new()
	#print(distance)
	pass
	

func add_chunk(x:int, y:int) -> void:
	var key = str(y) + "," + str(x)
	if chunks.has(key):
		return
		
	load_chunk(x, y, key)
	
	
func clean_up_chunks():
	for key in chunks:
		var chunk = chunks[key]
		if chunk.should_remove:
			chunk.queue_free()
			chunks.erase(key)
			
	
func clear_chunk(pos:Vector2i) -> void:
	self.chunks[pos.y][pos.x].clear()


func correction_factor(distance) -> float:
	if Globals.CAMERA_ZOOM_LEVEL < 0.6:
		return distance * 2.0	
	elif Globals.CAMERA_ZOOM_LEVEL > 1.0:
		return distance
	else:
		return distance * ( 1 + 2 * (1-Globals.CAMERA_ZOOM_LEVEL) )

func get_chunk(x:int, y:int):
	var key = str(y) + "," + str(x)
	if self.chunks.has(key):
		return chunks.get(key)
		
	return null
	

func load_chunk(x:int, y:int, key:String):
	var chunk = Chunk.new(x,y)
	self.add_child(chunk)
	chunks[key] = chunk	
	
	Globals.chunks_loaded += 1

	
func reset_chunks():
	for key in chunks:
		chunks[key].should_remove = true
		
	
func update_chunks():		 
	var p_x = int(Globals.CAMERA_POSITION.x- Globals.CHUNK_SIZE.x) / Globals.TILE_SIZE_X / Globals.CHUNK_SIZE.x
	var p_y = int(Globals.CAMERA_POSITION.y- Globals.CHUNK_SIZE.y) / Globals.TILE_SIZE_Y / Globals.CHUNK_SIZE.y
	
	# When updating chunks, adjust chunk rendering distance 
	# based on current zoom level.
	var zoom_corrected = correction_factor(distance)

	for y in Globals.map_size/Globals.CHUNK_SIZE.y:
		for x in Globals.map_size/Globals.CHUNK_SIZE.x:
			if (abs(x - p_x) <= zoom_corrected && abs(y - p_y) <= zoom_corrected):
				add_chunk(x, y)
				
				var chunk = get_chunk(x,y) 
				if chunk != null:
					chunk.should_remove = false


