class_name WorldGeneration
extends RefCounted

var image:Image = Image.new()	
var map_tile_data:Array[Array] = [[]] # store map tile info to a 2d array
var directions:Array = [
	Vector2i(0,1),	# south
	Vector2i(1,0),	# east
	Vector2i(0,-1), # north
	Vector2i(-1,0)  # west
	]

func choose_tile(tile:Vector2i, selected, surrounding) -> void:
	var surrounding_tiles:Array = []
			
	# determine which directions have land around the tile
	for dir in directions:
		# avoid index out of bounds
		if (tile.y+dir.y >= Globals.map_image_size.y) or (tile.x+dir.x >= Globals.map_image_size.x):
			surrounding_tiles.append(surrounding)
		elif map_tile_data[tile.y+dir.y][tile.x+dir.x] == surrounding:
			surrounding_tiles.append(surrounding)
		else:
			surrounding_tiles.append(selected)	
		
	# this is because a tile can have more than 1 option
	var selected_tile = Globals.td[surrounding].get(surrounding_tiles)
	var tile_coords:Vector2i
	if selected_tile == null:
		tile_coords = Globals.td[selected].get("default")[0]
	elif selected_tile.size() > 1:
		tile_coords = Globals.choose_randomly(selected_tile)
	else:
		tile_coords = selected_tile[0]
		
	# layer | position coords | tilemap id | coords of the tile at tilemap | alternative tile
	Globals.world_map.set_cell(
		Globals.LAYER_TERRAIN,
		Vector2i(tile.x, tile.y),
		2,
		tile_coords,
		0 if selected_tile else Globals.choose_randomly([0,1,2,3])
	)	
	
# Generates biomes, like forest and bog
func generate_biomes() -> void:
	# generate a new noisemap which should emulate forest-looking areas
	var fnl = FastNoiseLite.new()
	fnl.noise_type = FastNoiseLite.TYPE_PERLIN
	fnl.seed = 69 #randi()
	fnl.frequency = 0.1
	fnl.fractal_type = FastNoiseLite.FRACTAL_FBM
	fnl.fractal_octaves = 3
	fnl.fractal_lacunarity = 1
	fnl.fractal_gain = 1.746
	
	var water_next_to_tile:bool = false

	for y in map_tile_data.size():
		for x in map_tile_data[y].size():		
				
			# replace non-water with biomes			
			if map_tile_data[y][x] > 0:	
				water_next_to_tile = false
				
				# don't put forest next to water
				for dir in directions:
					if (y+dir.y >= Globals.map_image_size.y) or (x+dir.x >= Globals.map_image_size.x):
						continue
					if map_tile_data[y+dir.y][x+dir.x] == Globals.TILE_WATER:
						water_next_to_tile = true
				
				# if there's no water next to a land tile, it can be replaced with forest
				if !water_next_to_tile:
					var noise_sample = fnl.get_noise_2d(x,y)
					if noise_sample < 0.1:
						map_tile_data[y][x] = Globals.TILE_FOREST	
					# can add other tresholds here for other biomes

func generate_world(filename) -> bool:	
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
	
	read_image_pixel_data()
	smooth_land_features(Globals.TILE_WATER)  # smooth water	
	generate_biomes()
	smooth_land_features(Globals.TILE_FOREST) # smooth out forest
	set_tilemap_tiles()	

	return true

func read_image_pixel_data():
	# initialize the array to have enough rows
	map_tile_data.resize(Globals.map_image_size.y)
	
	for y in Globals.map_image_size.y:
		#initialize the row to have enough columns
		map_tile_data[y].resize(Globals.map_image_size.y)

		for x in Globals.map_image_size.x:
			if image.get_pixel(x, y) == Globals.WATER_TILE_COLOR_IN_MAP_FILE:
				map_tile_data[y][x] = Globals.TILE_WATER
			else:
				map_tile_data[y][x] = Globals.TILE_TERRAIN				
			
func set_tilemap_tiles() -> void:
	for y in map_tile_data.size():
		for x in map_tile_data[y].size():			
			# layer | position coords | tilemap id | coords of the tile at tilemap | alternative tile
			match map_tile_data[y][x]:
				Globals.TILE_WATER:	 # water or shoreline
					choose_tile(Vector2i(x, y), Globals.TILE_WATER, Globals.TILE_TERRAIN)
						
				Globals.TILE_TERRAIN: #terrain or forest edge
#					Globals.world_map.set_cell(
#						Globals.LAYER_TERRAIN,
#						Vector2i(x, y),
#						2,
#						Vector2i(0,0),
#						Globals.choose_randomly([0,1,2,3])
#					)
					choose_tile(Vector2i(x,y), Globals.TILE_TERRAIN, Globals.TILE_FOREST)
					
				Globals.TILE_FOREST:					
					Globals.world_map.set_cell(
						Globals.LAYER_TERRAIN,
						Vector2i(x, y),
						2,
						Vector2i(5,1),
						Globals.choose_randomly([0,1,2,3])
					)
						
				_:  #default
					pass
					

# Fill water tiles, surrounded in 3-4 sides by land, with land.
# Do it recursively with limit of n recursions!
func smooth_land_features(tile_type:int) -> void:
	# TODO for testing avoid map borders to make it simpler to implement			
	for y in range(1, Globals.map_image_size.y-1):
		for x in range(1, Globals.map_image_size.x-1):
			if map_tile_data[y][x] != tile_type:
				continue
				
			match tile_type:
				Globals.TILE_WATER:
					smooth_recursively(
						Vector2i(x, y),
						Globals.TILE_WATER,
						Globals.TILE_TERRAIN
					)
				Globals.TILE_FOREST:
					smooth_forest_recursively(
						Vector2i(x, y),
						Globals.TILE_FOREST,
						Globals.TILE_TERRAIN
					)
				
# TEMP SPAGHETTI SOLUTION	
func smooth_forest_recursively(pos:Vector2i, selected:int, comp:int) -> void:
	# now we are supposed to be inspecting a tile with land
	var surrounding_tiles:Array = []

	# determine which directions have land around the tile
	for dir in directions:
		if map_tile_data[pos.y+dir.y][pos.x+dir.x] == comp:
			surrounding_tiles.append(comp)
		elif map_tile_data[pos.y+dir.y][pos.x+dir.x] == selected:
			surrounding_tiles.append(selected)	

	match surrounding_tiles:
		[1,1,1,2]: #west
			map_tile_data[pos.y][pos.x] = comp	
			pos.x -= 1
		[1,1,2,1]: #north
			map_tile_data[pos.y][pos.x] = comp	
			pos.y -= 1
		[1,2,1,1]: #east
			map_tile_data[pos.y][pos.x] = comp	
			pos.x += 1
		[2,1,1,1]: #south
			map_tile_data[pos.y][pos.x] = comp	
			pos.y += 1
		[1,1,1,1]: # remove solo forests
			map_tile_data[pos.y][pos.x] = comp	
			return
		_:
			return 		
		
	#smooth_forest_recursively(pos, selected, comp)

func smooth_recursively(pos:Vector2i, selected:int, comp:int) -> void:
	# now we are supposed to be inspecting a tile with land
	var surrounding_tiles:Array = []

	# determine which directions have land around the tile
	for dir in directions:
		if map_tile_data[pos.y+dir.y][pos.x+dir.x] == comp:
			surrounding_tiles.append(comp)
		elif map_tile_data[pos.y+dir.y][pos.x+dir.x] == selected:
			surrounding_tiles.append(selected)	

	match surrounding_tiles:
		[1,1,1,0]: #west
			map_tile_data[pos.y][pos.x] = comp	
			pos.x -= 1
		[1,1,0,1]: #north
			map_tile_data[pos.y][pos.x] = comp	
			pos.y -= 1
		[1,0,1,1]: #east
			map_tile_data[pos.y][pos.x] = comp	
			pos.x += 1
		[0,1,1,1]: #south
			map_tile_data[pos.y][pos.x] = comp	
			pos.y += 1
		_:
			return 		
		
	smooth_recursively(pos, selected, comp)

func validate_mapgen_params() -> bool:
	if !Globals.are_coords_valid(
		Globals.map_image_size.y,
		Vector2i(Globals.MAP_MIN_HEIGHT, Globals.MAP_MAX_HEIGHT),
		Globals.ERROR_IMAGE_HEIGHT_INCORRECT):
		return false
		
	elif !Globals.are_coords_valid(
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
