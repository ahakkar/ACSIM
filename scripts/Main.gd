# OK - "Cube Clicker 2000" where you click a spot and a cube appears there.
# OK - Then add different shapes or colors of cubes.
# OK - Then clamp their positions to be on a grid.
# - Then make it so that when you add yellow cubes, yellow desire meter goes down and green meter goes up.
# - Then click a bunch of grey cubes in a row and have them automatically flatten out into flat grey cubes (roads).
# - Then click and drag to draw the lines of grey cubes.
# - etc.

extends Node

# Called when the node enters the scene tree for the first time.
func _ready():
	DisplayServer.window_set_size(
		Vector2i(Globals.DEFAULT_X_RES, Globals.DEFAULT_Y_RES)
	) 

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
