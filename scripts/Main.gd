# OK - "Cube Clicker 2000" where you click a spot and a cube appears there.
# OK - Then add different shapes or colors of cubes.
# OK - Then clamp their positions to be on a grid.
# - Then make it so that when you add yellow cubes, yellow desire meter goes down and green meter goes up.
# - Then click a bunch of grey cubes in a row and have them automatically flatten out into flat grey cubes (roads).
# - Then click and drag to draw the lines of grey cubes.
# - etc.

class_name Main
extends Node2D

signal set_camera_position(pos:Vector2)

# The idea is for the user to be able to choose the map from GUI later
var map_filenames:Array = [
	"res://maps/tampere_10x10km_1000px.png",
	"res://maps/tampere_10x10km_1024px.png",
	"res://maps/varkaus_256x256px_test.png",
	"res://maps/tampere_256px.png",
	"res://maps/tampere_10x10km_4096px.png"
	]
var map_filename:String = map_filenames[1]
var _world_generator:WorldGenerator
var _chunk_handler:ChunkHandler
#var _2d_camera:CameraZoom2D


func _init():
#	DisplayServer.window_set_size(
#		#Vector2i(Globals.DEFAULT_X_RES, Globals.DEFAULT_Y_RES)
#		Vector2i(3800,2000)
#	)
		Globals.CAMERA_POSITION = Vector2(16*256/2, 16*256/2)
		
#func _process(_delta):
#	Globals.CAMERA_POSITION = _2d_camera.position

# Called when the node enters the scene tree for the first time.
func _ready():	 
	# create a new world and worldgenerator
	_world_generator = WorldGenerator.new()
	_chunk_handler = ChunkHandler.new()
	#_2d_camera = CameraZoom2D.new()

	# add chunk handler if worldgen was successful
	if _world_generator.generate_world(map_filename):
		add_child(_chunk_handler)
		#add_child(_2d_camera)		
		
#		for y in Globals.map_size/Globals.CHUNK_SIZE.y:
#			for x in Globals.map_size/Globals.CHUNK_SIZE.x:
#				#if (y + x) % 2 == 0:
#				_chunk_handler.load_chunk(x, y)
	else:
		push_error("World generation failed :-(")
		
	# center camera to world map
	emit_signal(
		"set_camera_position", 
		Vector2(Globals.map_size / 2.0 * Globals.TILE_SIZE_X, 
				Globals.map_size / 2.0 * Globals.TILE_SIZE_Y)
	)
	
func quit_game():
	get_tree().get_root().propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
	#SceneTree.quit


