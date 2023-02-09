# OK - "Cube Clicker 2000" where you click a spot and a cube appears there.
# OK - Then add different shapes or colors of cubes.
# OK - Then clamp their positions to be on a grid.
# - Then make it so that when you add yellow cubes, yellow desire meter goes down and green meter goes up.
# - Then click a bunch of grey cubes in a row and have them automatically flatten out into flat grey cubes (roads).
# - Then click and drag to draw the lines of grey cubes.
# - etc.

extends Node

# The idea is for the user to be able to choose the map from GUI later
var map_file_name: String = "res://maps/tampere_200px_crop.png"

func _init():
	DisplayServer.window_set_size(
		Vector2i(Globals.DEFAULT_X_RES, Globals.DEFAULT_Y_RES)
	)
	
# Called when the node enters the scene tree for the first time.
func _ready():	 
	Globals.world_map = get_node("World")
	if !Globals.world_map:
		push_error(Globals.ERROR_MAKING_WORLD_INSTANCE)
		quit_game()
		
	# generate terrain. quit game if generation fails.	
	if !Globals.world_map.generate_terrain(map_file_name):
		push_error(Globals.ERROR_WHILE_GENERATING_MAP)
		quit_game()		

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
	
func quit_game():
	get_tree().get_root().propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
	#SceneTree.quit


