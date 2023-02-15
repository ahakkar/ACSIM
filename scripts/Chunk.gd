class_name Chunk
extends TileMap

var x:int = -1
var y:int = -1
var should_remove:bool = false


# Called when the node enters the scene tree for the first time.
func _init(ypos:int, xpos:int, sr: bool):
	self.x = xpos
	self.y = ypos
	self.should_remove = sr	
	
	#self.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC
	self.cell_quadrant_size = 32
	
	self.name = "Chunk [%d,%d]" % [x, y]	
	self.set_tileset(Globals.TILESET_TERRAIN)
	self.position = Vector2i(
		x*Globals.CHUNK_SIZE.x*Globals.TILE_SIZE_X,
		y*Globals.CHUNK_SIZE.y*Globals.TILE_SIZE_Y
		)
		
		
func _ready():
	generate_chunk()
	
	
# draws borders around the chunk
#func _draw():
#	self.draw_rect(
#		Rect2(
#			Vector2(0,0),
#			Vector2(
#				Globals.CHUNK_SIZE.x*Globals.TILE_SIZE_X, 
#				Globals.CHUNK_SIZE.y*Globals.TILE_SIZE_Y)
#			),
#		Color(0,0,0,0.5),
#		false
#		)


func generate_chunk() -> void:	
	for row in Globals.CHUNK_SIZE.y:
		for col in Globals.CHUNK_SIZE.x:			
			var tile_data: Array = Globals.map_tile_data[row+y*Globals.CHUNK_SIZE.y][col+x*Globals.CHUNK_SIZE.x]			
			# layer | tile coords at tilemap | tilemap id | coords of the tile at tileset | alternative tile
			self.set_cell(
				Globals.LAYER_TERRAIN,
				Vector2i(col, row),
				0,
				tile_data[0],
				tile_data[1]
			)



