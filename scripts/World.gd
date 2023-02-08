extends TileMap

signal set_camera_position(pos:Vector2)

var has_placeable_building: bool = false
var building
var building_type: String
var scene

# Called when the node enters the scene tree for the first time.
func _ready():	
	pass
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func get_building_properties() -> Array:
	var tileset_id = 0 # default value
	var tilemap_tile_coords: Vector2i
	
	if building_type == null:
		push_error(Globals.ERROR_BUILDING_TYPE_NOT_SET)
		return []
	
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
			
	return [tileset_id, tilemap_tile_coords]	

func _on_control_button_pressed(type):	
	self.building_type = type	
	
	# create new building, in Building node it is attached to mouse cursor
	var building_properties = get_building_properties()	
	scene = load(Globals.SCENE_PATH + "Building.tscn")	
	building = scene.instantiate()	
	#building.set_cell(0, Vector2i(0,0), building_properties[0], building_properties[1], 0)
	add_child(building)
	
	has_placeable_building = true	

func _input(event):	
	# place the building
	if event.is_action_pressed("place_building") and has_placeable_building:
		has_placeable_building = false
		place_building_to_map()
	
	# cancel placement
	if event.is_action_pressed("cancel"):
		if has_placeable_building:
			pass
			
func calculate_grid_coordinates(map_position: Vector2) -> Vector2:
	return (map_position).floor()
	
func are_coords_valid(value:int, errmsg:String) -> bool:
	if Globals.MAP_MIN_HEIGHT > value or value > Globals.MAP_MAX_HEIGHT:		
		errmsg = errmsg % [value, Globals.MAP_MIN_HEIGHT, Globals.MAP_MAX_HEIGHT]
		push_error(errmsg)
		return false
	
	return true

func place_building_to_map():
	var building_properties = get_building_properties()
	var tile_on_mouse = local_to_map(get_global_mouse_position())
	
	if !are_coords_valid(tile_on_mouse.y,Globals.ERROR_TILE_Y_COORDS_OUT_OF_BOUNDS):
		return false
	elif !are_coords_valid(tile_on_mouse.x,Globals.ERROR_TILE_X_COORDS_OUT_OF_BOUNDS):
		return false	

	set_cell(Globals.LAYER_BUILDINGS, tile_on_mouse, building_properties[0], building_properties[1], 0)

func generate_terrain(filename) -> bool:	
	# Try to load the image which we used to place water & ground to world map
	var image:Image = Image.new()		
	image = load(filename)		
	if image == null:
		var errmsg = Globals.ERROR_FAILED_TO_LOAD_FILE
		push_error(errmsg % filename)
		return false
				
	# Check if image is too small or too large
	var image_size:Vector2i = image.get_size()
	if !are_coords_valid(image_size.y,Globals.ERROR_IMAGE_HEIGHT_INCORRECT):
		return false
	elif !are_coords_valid(image_size.x,Globals.ERROR_IMAGE_WIDTH_INCORRECT):
		return false
		
	# Try to load the world tilemap where we place the tiles
	if (Globals.world_map == null):
		var errmsg = Globals.ERROR_WORLD_TILEMAP_NODE_MISSING % Globals.WORLD_NODE
		push_error(errmsg)
		return false	
		
	# Finally populate the world map with hopefully valid tiles!	
	for x in image_size.x:
		for y in image_size.y:
			# layer | position coords | tilemap id | coords of the tile at tilemap | alternative tile
			if image.get_pixel(x, y) == Globals.WATER_TILE_COLOR_IN_MAP_FILE:
				Globals.world_map.set_cell(Globals.LAYER_TERRAIN, Vector2i(x, y), 2, Vector2i(0,0), 0)	
	
	# center camera to world map
	emit_signal(
		"set_camera_position", 
		Vector2(image_size.x/2.0*Globals.TILE_SIZE_X, image_size.y/2.0*Globals.TILE_SIZE_Y)
	)
	return true
