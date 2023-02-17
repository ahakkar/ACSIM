class_name EventBus
extends Node

@onready var node_main:Main
@onready var node_mainmenu:MainMenu
@onready var node_game:Game
@onready var node_camera:Camera
@onready var node_uilayer:UILayer


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


func _process(_delta) -> void:	
	while Input.is_action_pressed("camera_rotate_left_stepless"):
		node_camera.camera_rotate(-0.1)
		await get_tree().create_timer(0.2).timeout
	while Input.is_action_pressed("camera_rotate_right_stepless"):
		node_camera.camera_rotate(0.1)
		await get_tree().create_timer(0.2).timeout


func _ready():
	node_main = get_parent()	
	node_mainmenu = find_child("MainMenu")
	node_game = find_child("Game")
	node_camera = find_child("Camera")
	node_uilayer = find_child("UILayer")	
	
	
func set_ready():
	node_mainmenu.set_ready()	

	
func _unhandled_input(event) -> void:	
	if !node_camera:		
		return
	###################################
	# MAIN MENU						  #
	###################################
	
	if event.is_action_pressed("open_main_menu"):
		# move mainmenu to current game camera position
		var mainmenu_pos = Globals.CAMERA_POSITION
		mainmenu_pos.x -= DisplayServer.window_get_size(0).x/2 
		mainmenu_pos.y -= DisplayServer.window_get_size(0).y/2
		node_mainmenu.set_position(mainmenu_pos, false)

		# show the menu
		node_mainmenu.set_visible(true)
		node_game.set_visible(false)
		node_uilayer.set_visible(false)
		node_main.pause_game()
		
	###################################
	# GAME CAMERA					  #
	###################################
		
	if event.is_action_pressed("camera_zoom_in"):			
		node_camera.camera_zoom_in()
	if event.is_action_pressed("camera_zoom_out"):
		node_camera.camera_zoom_out()
		
	if event.is_action_pressed("camera_rotate_left_fixed_step"):		
		node_camera.camera_rotate(-45)
	if event.is_action_pressed("camera_rotate_right_fixed_step"):
		node_camera.camera_rotate(45)		
	if event.is_action_pressed("camera_reset_rotation"):
		node_camera.camera_reset_rotation()
		
	if event.is_action_pressed("take_screenshot"):
		node_camera.camera_take_screenshot()		

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:		
		if !node_camera.get_camera_panning() and event.pressed:
			node_camera.set_camera_panning(true)
		if node_camera.get_camera_panning() and !event.pressed:
			node_camera.set_camera_panning(false)

	if event is InputEventMouseMotion and node_camera.get_camera_panning():		
		# rotate event.relative vector with camera rotation so camera moves to "correct" direction
		node_camera.camera_pan_position(event.relative.rotated(node_camera.get_camera_rotation()) * Globals.CAMERA_PAN_MULTI)
		
		# prevent camera from going overboard
		node_camera.clamp_camera_position()


func _on_mainmenu_button_pressed(button:int):
	match button:
		Globals.MAINMENU_NEW_GAME:			
			start_new_game()
			
		Globals.MAINMENU_LOAD_GAME:
			pass
			
		Globals.MAINMENU_RESUME_GAME:
			resume_game()
			
		Globals.MAINMENU_OPTIONS:
			pass
			
		Globals.MAINMENU_CREDITS:
			pass
			
		Globals.MAINMENU_QUIT_GAME:
			node_main.quit_game()
			
		_:
			push_error("Error: Main: unknown signal at _on_mainmenu_button_pressed: ", button)
			

func resume_game() -> void:
	# TODO save camera position before opening menu, restore camera position when closing menu
	node_main.unpause_game()
	node_mainmenu.set_visible(false)
	node_game.set_visible(true)
	node_uilayer.set_visible(true)
	

func set_camera_position(pos:Vector2):
	node_camera.set_camera_position(pos)
	

func start_new_game():
	# create a new world with worldgenerator
	_world_generator = WorldGenerator.new()	
	if !_world_generator.generate_world(map_filename):
		push_error("World generation failed :-(")
		node_main.quit_game()
	
	# after generating the world we know what limits we should set to camera	
	node_camera.set_camera_limits()
		
	node_mainmenu.find_child("Menu_NewGame").disabled = true
	node_mainmenu.find_child("Menu_ResumeGame").disabled = false
		
	# unpause game and setup it
	node_main.unpause_game()
	node_game.set_ready()
	node_uilayer.set_ready()
	
	# hide menu, display game & ui
	node_mainmenu.set_visible(false)
	node_game.set_visible(true)
	node_uilayer.set_visible(true)
	
	var node_infolayer:InfoLayer
	node_infolayer = find_child("InfoLayer")
	node_infolayer.set_visible(true)
	
	# set camera to center of the map
	node_camera.camera_reset_rotation()
	node_camera.set_camera_position(
		Vector2(Globals.map_size / 2.0 * Globals.TILE_SIZE_X, 
		Globals.map_size / 2.0 * Globals.TILE_SIZE_Y)
		)
		
		
	



