class_name Chunk
extends TileMap

var x:int = -1
var y:int = -1

# Called when the node enters the scene tree for the first time.
func _init(xpos:int, ypos:int):
	self.x = xpos
	self.y = ypos	
	self.name = "Chunk [%d,%d]" % [x, y]	
	self.set_tileset(Globals.TILESET_TERRAIN)
	self.position = Vector2i(
		x*Globals.CHUNK_SIZE*Globals.TILE_SIZE_X,
		y*Globals.CHUNK_SIZE*Globals.TILE_SIZE_Y
		)

func generate_chunk() -> void:	
	for row in Globals.CHUNK_SIZE:
		for col in Globals.CHUNK_SIZE:
			var tile_data: Array = Globals.map_tile_data[row+y*Globals.CHUNK_SIZE][col+x*Globals.CHUNK_SIZE]			
			# layer | tile coords at tilemap | tilemap id | coords of the tile at tileset | alternative tile
			self.set_cell(
				Globals.LAYER_TERRAIN,
				Vector2i(col, row),
				0,
				tile_data[0],
				tile_data[1]
			)



