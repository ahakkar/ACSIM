extends TileMap

signal set_camera_position(pos:Vector2)

var building : bool = false
var building_type: String
#var scene

# Called when the node enters the scene tree for the first time.
func _ready():	
	pass
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func _on_control_button_pressed(type):
	# create new building, in Building node it is attached to mouse cursor
	#scene = load(Globals.SCENE_PATH + "Building.tscn")
	#building = scene.instantiate()	
	#add_child(building)	
	self.building = true
	self.building_type = type

	#print(button_name + " button pressed in Control! :-0")
	pass

func _input(event):	
	# place the building
	if event.is_action_pressed("place_building") and building != false:
		# stop processing the sprite (fix it in place). no idea if it is a good idea yet..	
		#building.set_process(false)
		building = false
		place_building_to_map(event)
	
	# cancel placement
	if event.is_action_pressed("cancel"):
		if building != false:
			pass
			
func calculate_grid_coordinates(map_position: Vector2) -> Vector2:
	return (map_position).floor()

func place_building_to_map(event):
	var tileset_id = 0 # default value
	var tilemap_tile_coords: Vector2i
	
	# layer | position coords | tileset id | coords of the tile at tilemap | alternative tile		
	match building_type:
		Globals.TYPE_RESIDENTIAL:
			tilemap_tile_coords = Vector2i(0,0) 
			tileset_id = 0
		Globals.TYPE_COMMERCIAL:
			tilemap_tile_coords = Vector2i(4,12)
			tileset_id = 1
		Globals.TYPE_INDUSTRIAL:
			tilemap_tile_coords = Vector2i(4,20)
			tileset_id = 1
		Globals.TYPE_ROADS:
			tilemap_tile_coords = Vector2i(14,2)
			tileset_id = 1
		Globals.TYPE_DEMOLISH:
			tilemap_tile_coords = Vector2i(4,4)
			tileset_id = 1
		Globals.TYPE_SERVICES:
			tilemap_tile_coords = Vector2i(4,8)
			tileset_id = 1
		Globals.TYPE_SOCIAL:
			tilemap_tile_coords = Vector2i(4,0)
			tileset_id = 1
		_:	#default
			tilemap_tile_coords = Vector2i(16,16)
			tileset_id = 1
			
	var mouse_pos = local_to_map(get_global_mouse_position())
	set_cell(Globals.LAYER_BUILDINGS, mouse_pos, tileset_id, tilemap_tile_coords, 0)
	#print("cell set at layer ", Globals.LAYER_BUILDINGS)
	#print("cellpos:", local_to_map(get_global_mouse_position()))
	#print("event position:", event.position)

func generate_terrain(filename) -> bool:	
	# Try to load the image which we used to place water & ground to world map
	var image:Image = Image.new()		
	image = load(filename)		
	if image == null:
		var errmsg = Globals.ERROR_FAILED_TO_LOAD_FILE
		push_error(errmsg % filename)
		return false
		
	var image_height:int = image.get_height()
	var image_width:int = image.get_width()
		
	# Check if image is too small or too large
	if Globals.MAP_MIN_HEIGHT > image_height or image_height > Globals.MAP_MAX_HEIGHT:
		var errmsg = Globals.ERROR_IMAGE_HEIGHT_INCORRECT
		errmsg = errmsg % [image_height, Globals.MAP_MIN_HEIGHT, Globals.MAP_MAX_HEIGHT]
		push_error(errmsg)
		return false
	elif Globals.MAP_MIN_WIDTH > image_width or image_width > Globals.MAP_MAX_WIDTH:
		var errmsg = Globals.ERROR_IMAGE_WIDTH_INCORRECT
		errmsg = errmsg % [image_width, Globals.MAP_MIN_WIDTH, Globals.MAP_MAX_WIDTH]
		push_error(errmsg)
		return false
		
	# Try to load the world tilemap where we place the tiles
	if (Globals.world_map == null):
		print("World TileMap node missing or name is wrong.\n
			  Tried to load: '%s'", Globals.WORLD_NODE)
		return false	
		
	# Finally populate the world map with hopefully valid tiles!	
	for x in image_width:
		for y in image_height:
			# layer | position coords | tilemap id | coords of the tile at tilemap | alternative tile
			if image.get_pixel(x, y) == Globals.WATER_TILE_COLOR_IN_MAP_FILE:
				Globals.world_map.set_cell(Globals.LAYER_TERRAIN, Vector2i(x, y), 2, Vector2i(0,0), 0)	
	
	# center camera to world map
	emit_signal(
		"set_camera_position", 
		Vector2(image_height/2.0*Globals.TILE_SIZE_X, image_width/2.0*Globals.TILE_SIZE_Y)
	)
	return true
