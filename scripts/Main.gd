# OK - "Cube Clicker 2000" where you click a spot and a cube appears there.
# OK - Then add different shapes or colors of cubes.
# OK - Then clamp their positions to be on a grid.
# - Then make it so that when you add yellow cubes, yellow desire meter goes down and green meter goes up.
# - Then click a bunch of grey cubes in a row and have them automatically flatten out into flat grey cubes (roads).
# - Then click and drag to draw the lines of grey cubes.
# - etc.

class_name Main
extends Node

# The idea is for the user to be able to choose the map from GUI later
var map_filename: String = "res://maps/varkaus_256x256px_test.png"
var _world := World.new()
var _world_generator := WorldGeneration.new()

func _init():
	DisplayServer.window_set_size(
		#Vector2i(Globals.DEFAULT_X_RES, Globals.DEFAULT_Y_RES)
		Vector2i(3800,2000)
	)
	
# Called when the node enters the scene tree for the first time.
func _ready():	 
	if !_world:
		push_error(Globals.ERROR_MAKING_WORLD_INSTANCE)
		quit_game()
		
	# generate terrain. quit game if generation fails.	
	if !_world_generator.generate_world(map_filename):
		push_error(Globals.ERROR_WHILE_GENERATING_MAP)
		quit_game()		

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
	
func quit_game():
	get_tree().get_root().propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
	#SceneTree.quit


