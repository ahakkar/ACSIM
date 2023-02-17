class_name EventBus
extends Node

@onready var node_main = get_parent()
@onready var node_mainmenu = find_child("MainMenu")
@onready var node_game = find_child("Game")


# The idea is for the user to be able to choose the map from GUI later
var map_filenames:Array = [
	"res://maps/tampere_10x10km_1000px.png",
	"res://maps/tampere_10x10km_1024px.png",
	"res://maps/varkaus_256x256px_test.png",
	"res://maps/tampere_256px.png",
	"res://maps/tampere_10x10km_4096px.png"
	]
var map_filename:String = map_filenames[3]
var _world_generator:WorldGenerator


func _process(_delta) -> void:	
	while Input.is_action_pressed("camera_rotate_left_stepless"):
		node_game.camera_rotate(-0.1)
		await get_tree().create_timer(0.2).timeout
	while Input.is_action_pressed("camera_rotate_right_stepless"):
		node_game.camera_rotate(0.1)
		await get_tree().create_timer(0.2).timeout


func _ready():
	node_mainmenu.set_ready()	

	
func _unhandled_input(event) -> void:
	###################################
	# MAIN MENU						  #
	###################################
	
	if event.is_action_pressed("open_main_menu"):
		# move mainmenu to current game camera position
		var mainmenu_pos = Globals.CAMERA_POSITION
		mainmenu_pos.x -= DisplayServer.window_get_size(0).x/2 
		mainmenu_pos.y -= DisplayServer.window_get_size(0).y/2
		self.find_child("MainMenu").position = mainmenu_pos

		# show the menu
		toggle_main_menu_visibility()
		#await get_tree().create_timer(0.2).timeout
		self.find_child("Game").process_mode = PROCESS_MODE_DISABLED
		
	###################################
	# GAME CAMERA					  #
	###################################
		
	if event.is_action_pressed("camera_zoom_in"):
		node_game.camera_zoom_in()
	if event.is_action_pressed("camera_zoom_out"):
		node_game.camera_zoom_out()
		
	if event.is_action_pressed("camera_rotate_left_fixed_step"):		
		node_game.camera_rotate(-45)
	if event.is_action_pressed("camera_rotate_right_fixed_step"):
		node_game.camera_rotate(45)		
	if event.is_action_pressed("camera_reset_rotation"):
		node_game.camera_reset_rotation()
		
	if event.is_action_pressed("take_screenshot"):
		node_game.take_screenshot()		

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:		
		if !node_game.camera_get_panning() and event.pressed:			
			node_game.camera_set_panning(true)
		if node_game.camera_get_panning() and !event.pressed:
			node_game.camera_set_panning(false)

	if event is InputEventMouseMotion and node_game.camera_get_panning():		
		# rotate event.relative vector with camera rotation so camera moves to "correct" direction
		node_game.camera_pan_position(event.relative.rotated(node_game.camera_get_rotation()) * Globals.CAMERA_PAN_MULTI)
		
		# prevent camera from going overboard
		node_game.camera_clamp_position()


func _on_mainmenu_button_pressed(button:int):
	match button:
		Globals.MAINMENU_NEW_GAME:
			start_new_game()
			node_mainmenu.find_child("Menu_NewGame").disabled = true
			node_mainmenu.find_child("Menu_ResumeGame").disabled = false
			toggle_main_menu_visibility()
			
		Globals.MAINMENU_LOAD_GAME:
			pass
			
		Globals.MAINMENU_RESUME_GAME:
			# TODO save camera position before opening menu, restore camera position when closing menu
			node_game.process_mode = PROCESS_MODE_INHERIT
			toggle_main_menu_visibility()
			
		Globals.MAINMENU_OPTIONS:
			pass
			
		Globals.MAINMENU_CREDITS:
			pass
			
		Globals.MAINMENU_QUIT_GAME:
			node_mainmenu.quit_game()
			
		_:
			push_error("Error: Main: unknown signal at _on_mainmenu_button_pressed: ", button)


func start_new_game():
	# create a new world with worldgenerator
	_world_generator = WorldGenerator.new()	
	if !_world_generator.generate_world(map_filename):
		push_error("World generation failed :-(")
		node_main.quit_game()
		
	node_main.unpause_game()
	node_game.set_ready()
	self.set_camera_position(
		Vector2(Globals.map_size / 2.0 * Globals.TILE_SIZE_X, 
		Globals.map_size / 2.0 * Globals.TILE_SIZE_Y)
		)
	

func toggle_main_menu_visibility():
	node_game.toggle_visibility()
		
	if node_mainmenu.visible:
		node_mainmenu.hide()
	else:
		node_mainmenu.show()	

func set_camera_position(pos:Vector2):
	node_game.camera_set_position(pos)
	


