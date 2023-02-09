extends TileMap

signal set_camera_position(pos:Vector2)

var has_placeable_building: bool = false
var building
var building_type: String
var scene
var image:Image = Image.new()	

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
	
func are_coords_valid(value:int, bounds:Vector2i, errmsg:String) -> bool:
	if bounds.x > value or value > bounds.y:		
		errmsg = errmsg % [value, bounds.x, bounds.y]
		push_error(errmsg)
		return false
	
	return true

func place_building_to_map():
	var building_properties = get_building_properties()
	var tile_on_mouse = local_to_map(get_global_mouse_position())
	
	if !are_coords_valid(
		tile_on_mouse.y,
		Vector2i(0, Globals.map_image_size.y),
		Globals.ERROR_TILE_Y_COORDS_OUT_OF_BOUNDS
	):
		return false
	elif !are_coords_valid(
		tile_on_mouse.x,
		Vector2i(0, Globals.map_image_size.x),
		Globals.ERROR_TILE_X_COORDS_OUT_OF_BOUNDS
	):
		return false	

	set_cell(Globals.LAYER_BUILDINGS, tile_on_mouse, building_properties[0], building_properties[1], 0)

func generate_terrain(filename) -> bool:	
	# Try to load the image which we used to place water & ground to world map		
	image = load(filename)		
	if image == null:
		var errmsg = Globals.ERROR_FAILED_TO_LOAD_FILE
		push_error(errmsg % filename)
		return false
				
	# Check if image is too small or too large
	Globals.map_image_size = image.get_size()		
	if !validate_mapgen_params():
		return false
		
	generate_water_and_land()
	generate_shorelines()
	
	# center camera to world map
	emit_signal(
		"set_camera_position", 
		Vector2(Globals.map_image_size.x / 2.0 * Globals.TILE_SIZE_X, 
				Globals.map_image_size.y / 2.0 * Globals.TILE_SIZE_Y)
	)
	return true
	
func validate_mapgen_params() -> bool:
	if !are_coords_valid(
		Globals.map_image_size.y,
		Vector2i(Globals.MAP_MIN_HEIGHT, Globals.MAP_MAX_HEIGHT),
		Globals.ERROR_IMAGE_HEIGHT_INCORRECT):
		return false
	elif !are_coords_valid(
		Globals.map_image_size.x,
		Vector2i(Globals.MAP_MIN_WIDTH, Globals.MAP_MAX_WIDTH),
		Globals.ERROR_IMAGE_WIDTH_INCORRECT):
		return false
		
	# Try to load the world tilemap where we place the tiles
	if (Globals.world_map == null):
		var errmsg = Globals.ERROR_WORLD_TILEMAP_NODE_MISSING % Globals.WORLD_NODE
		push_error(errmsg)
		return false
		
	return true
	
func generate_water_and_land() -> void:
	for x in Globals.map_image_size.x:
		for y in Globals.map_image_size.y:
			# layer | position coords | tilemap id | coords of the tile at tilemap | alternative tile
			if image.get_pixel(x, y) == Globals.WATER_TILE_COLOR_IN_MAP_FILE:
				Globals.world_map.set_cell(Globals.LAYER_TERRAIN, Vector2i(x, y), 2, Vector2i(15,5), 0)	
			else:
				Globals.world_map.set_cell(Globals.LAYER_TERRAIN, Vector2i(x, y), 2, Vector2i(0,0), 0)	
				
func generate_shorelines() -> void:
	# for testing avoid map borders to make it simpler to implement
	var directions:Array = [
		Vector2i(0,1),	# south
		Vector2i(1,0),	# east
		Vector2i(0,-1), # north
		Vector2i(-1,0)  # west
		]
		
	for x in range(1, Globals.map_image_size.x-1):
		for y in range(1, Globals.map_image_size.y-1):
			# skip tiles with water
			if image.get_pixel(x, y) == Globals.WATER_TILE_COLOR_IN_MAP_FILE:
				continue
				
			# now we are supposed to be inspecting a tile with land
			# 1 = water 0 = land
			var surrounding_water_tiles:Array = []
			
			# determine which directions have water around the tile
			for dir in directions:
				if image.get_pixel(x+dir.x, y+dir.y) == Globals.WATER_TILE_COLOR_IN_MAP_FILE:
					surrounding_water_tiles.append(1)
					continue
				surrounding_water_tiles.append(0)	
				
			var selected_tile:Vector2i = Vector2i(0,0)
			
			match surrounding_water_tiles:					
				[1,1,0,0]: # south & east
					selected_tile = Vector2i(19,0) # or 20	
				[0,1,1,0]: # north & east
					selected_tile = Vector2i(15,0) # or 60	
				[0,0,1,1]: # north & west
					selected_tile = Vector2i(11,0) # or 12	
				[1,0,0,1]: # south & west
					selected_tile = Vector2i(7,0) # or 8
				[0,0,0,1]: # water in west only
					selected_tile = Vector2i(9,0) # or 10
				[0,0,1,0]: # water in north only
					selected_tile = Vector2i(13,0) # or 14
				[0,1,0,0]: # water in east only
					selected_tile = Vector2i(17,0) # or 18
				[1,0,0,0]: # water in south only
					selected_tile = Vector2i(5,0) # or 6
				_: # otherwise skip drawing
					continue				
						
			# layer | position coords | tilemap id | coords of the tile at tilemap | alternative tile			
			Globals.world_map.set_cell(Globals.LAYER_TERRAIN, Vector2i(x, y), 2, selected_tile, 0)	
			
	
