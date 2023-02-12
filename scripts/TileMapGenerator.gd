class_name TileMapGenerator
extends CanvasLayer

# one tilemap is one chunk
# map consists of many chunks
# chunks are loaded to view when needed
# chunks are deleted after they are no longer needed (in view)

# This is done to speed up game loading and avoiding setting one large tilemap in one go
# which is extremely slow in godot 4.0, 4096x4096 takes minutes to fill with set_cell() commands

const CHUNK_SIZE = Vector2i(128,128)

var map_tiles:Array[Array] = [[]]

func start() -> void:
	# Initialize the map tile array with enough chunks to cover the whole map
	
	var ms:int = Globals.map_size.y/CHUNK_SIZE.y
	map_tiles.resize(2)
	print("map tiles size y: ", map_tiles.size())
	
	for y in ms:
		map_tiles[y].resize(2)
		print("map tiles size x: ", map_tiles[y].size())		
		for x in ms:	
			map_tiles[y][x] = TileMap.new()			
	
func test_func():
	self.set_chunk_tiles(Vector2i(1,0))
	#self.map_tiles[0][1].visible()
	print(map_tiles[0][1])
	
func clear_chunk_tiles(chunk_pos:Vector2i) -> void:
	map_tiles[chunk_pos.y][chunk_pos.x].clear()

func set_chunk_tiles(chunk_pos:Vector2i) -> void:
	# Set an invidiual chunk's tiles based on map terrain data
	
	# Try to load the world tilemap where we place the tiles
	if (map_tiles[chunk_pos.y][chunk_pos.x] == null):
		var errmsg = Globals.ERROR_TILEMAP_NODE_MISSING
		push_error(errmsg % str(chunk_pos))
		#return false
		
	for y in CHUNK_SIZE.y:
		for x in CHUNK_SIZE.x:
			var tile_data: Array = Globals.map_tile_data[chunk_pos.y*CHUNK_SIZE.y][chunk_pos.x*CHUNK_SIZE.x]
			
			# layer | tile coords at tilemap | tilemap id | coords of the tile at tileset | alternative tile
			map_tiles[chunk_pos.y][chunk_pos.x].set_cell(
				Globals.LAYER_TERRAIN,
				Vector2i(x, y),
				2,
				tile_data[0],
				tile_data[1]
			)
