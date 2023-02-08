# OK - "Cube Clicker 2000" where you click a spot and a cube appears there.
# OK - Then add different shapes or colors of cubes.
# OK - Then clamp their positions to be on a grid.
# - Then make it so that when you add yellow cubes, yellow desire meter goes down and green meter goes up.
# - Then click a bunch of grey cubes in a row and have them automatically flatten out into flat grey cubes (roads).
# - Then click and drag to draw the lines of grey cubes.
# - etc.

extends Node

var world_map: TileMap

func _init():
	DisplayServer.window_set_size(
		Vector2i(Globals.DEFAULT_X_RES, Globals.DEFAULT_Y_RES)
	)
	
# Called when the node enters the scene tree for the first time.
func _ready():	 
	generate_terrain()
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func generate_terrain():
	world_map = get_node("World")
	var image = Image.new()
	image.load("res://maps/tampere_10x10km_1000px.png")		
		
	for x in 1000:
		for y in 1000:
			# layer | position coords | tilemap id | coords of the tile at tilemap | alternative tile
			if image.get_pixel(x, y) == Color(1,1,1,1):
				world_map.set_cell(0, Vector2i(x, y), 2, Vector2i(0,0), 0)
