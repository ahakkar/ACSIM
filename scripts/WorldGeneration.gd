class_name WorldGeneration
extends RefCounted

signal set_camera_position(pos:Vector2)

var image:Image = Image.new()	
var map_tile_data:Array[Array] = [[]] # store map tile info to a 2d array
var directions:Array = [
	Vector2i(0,1),	# south
	Vector2i(1,0),	# east
	Vector2i(0,-1), # north
	Vector2i(-1,0)  # west
	]
	
var count:int = 0

func choose_forest_tile(tile:Vector2i) -> Vector2i:
	var surrounding_tiles:Array = []
			
	# determine which directions have forest around the tile
	for dir in directions:
		# avoid index out of bounds
		if (tile.y+dir.y >= Globals.map_image_size.y) or (tile.x+dir.x >= Globals.map_image_size.x):
			surrounding_tiles.append(Globals.TILE_TERRAIN)
		elif map_tile_data[tile.y+dir.y][tile.x+dir.x] == Globals.TILE_FOREST:
			surrounding_tiles.append(Globals.TILE_FOREST)
			continue
		surrounding_tiles.append(Globals.TILE_TERRAIN)	
		
	var selected_tile = match_forest_tile(surrounding_tiles)
	if selected_tile.x == -1 or selected_tile.y == -1:
		selected_tile = Vector2i(0,0)
		
	return selected_tile

func choose_tile(tile:Vector2i) -> Vector2i:
	var surrounding_tiles:Array = []
			
	# determine which directions have land around the tile
	for dir in directions:
		# avoid index out of bounds
		if (tile.y+dir.y >= Globals.map_image_size.y) or (tile.x+dir.x >= Globals.map_image_size.x):
			surrounding_tiles.append(Globals.TILE_WATER)
		elif map_tile_data[tile.y+dir.y][tile.x+dir.x] == Globals.TILE_TERRAIN:
			surrounding_tiles.append(Globals.TILE_TERRAIN)
			continue
		surrounding_tiles.append(Globals.TILE_WATER)	
		
	var selected_tile = match_tile(surrounding_tiles)
	if selected_tile.x == -1 or selected_tile.y == -1:
		selected_tile = Vector2i(1,0)
		
	return selected_tile

func choose_randomly(list_of_entries:Array[int]) -> int:
	return list_of_entries[randi() % list_of_entries.size()]
	
# Generates biomes, like forest and bog
func generate_biomes() -> void:
	
	print("biome generation")
	var fnl = FastNoiseLite.new()
	fnl.noise_type = FastNoiseLite.TYPE_PERLIN
	fnl.seed = randi()
	fnl.frequency = 0.1
	fnl.fractal_type = FastNoiseLite.FRACTAL_FBM
	fnl.fractal_octaves = 3
	fnl.fractal_lacunarity = 1
	fnl.fractal_gain = 1.746
	
	var water_next_to_tile:bool = false
	
	#var noise_img = Image.new()
	#noise_img = fnl.get_image(Globals.map_image_size.x, Globals.map_image_size.y)
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
				
				if !water_next_to_tile:
					var noise_sample = fnl.get_noise_2d(x,y)
					if noise_sample < 0.1:
						count += 1
						map_tile_data[y][x] = Globals.TILE_FOREST	
					
	print("maata korvattu ", count)

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
	smooth_land_features()
	generate_biomes()
	set_tilemap_tiles()
	
	# center camera to world map
	emit_signal(
		"set_camera_position", 
		Vector2(Globals.map_image_size.x / 2.0 * Globals.TILE_SIZE_X, 
				Globals.map_image_size.y / 2.0 * Globals.TILE_SIZE_Y)
	)
	return true
	
func match_forest_tile(surrounding_tiles) -> Vector2i:
	match surrounding_tiles:		
		# 4 forest tiles around land
		[2,2,2,2]:
			return Vector2i(5,1) # forest tile
			
		# 3 forest tiles around land
		[2,2,2,1]:
			return Vector2i(5,1) # forest tile	
		[2,2,1,2]:
			return Vector2i(5,1) # forest tile	
		[2,1,2,2]:
			return Vector2i(5,1) # forest tile	
		[1,2,2,2]:
			return Vector2i(5,1) # forest tile	
			
		# 2 forest tiles around land
		[2,2,1,1]: # south & east
			return Vector2i(28,0)
		[1,2,2,1]: # north & east
			return Vector2i(26,0)
		[1,1,2,2]: # north & west
			return Vector2i(24,0)
		[2,1,1,2]: # south & west
			return Vector2i(22,0)
			
		# 1 forest tile around land
		[1,1,1,2]: # west only
			return Vector2i(23,0)
		[1,1,2,1]: # north only
			return Vector2i(25,0)
		[1,2,1,1]: # east only
			return Vector2i(27,0)
		[2,1,1,1]: # south only
			return Vector2i(29,0)
			
		_: # otherwise skip drawing
			return Vector2i(-1,-1)
	
func match_tile(surrounding_tiles) -> Vector2i:
	match surrounding_tiles:		
		# 4 land tiles around water
		[1,1,1,1]:
			return Vector2i(0,0) # land tile
			
		# 3 land tiles around water
		[1,1,1,0]:
			return Vector2i(0,0) # land tile	
		[1,1,0,1]:
			return Vector2i(0,0) # land tile	
		[1,0,1,1]:
			return Vector2i(0,0) # land tile	
		[0,1,1,1]:
			return Vector2i(0,0) # land tile	
			
		# 2 land tiles around water		
		[1,1,0,0]: # south & east
			return Vector2i(choose_randomly([11,12]),0)
		[0,1,1,0]: # north & east
			return Vector2i(choose_randomly([7,8]),0)
		[0,0,1,1]: # north & west
			return Vector2i(choose_randomly([19,20]),0)
		[1,0,0,1]: # south & west
			return Vector2i(choose_randomly([15,16]),0)
			
		# 1 land tile around water
		[0,0,0,1]: # west only
			return Vector2i(choose_randomly([17,18]),0)
		[0,0,1,0]: # north only
			return Vector2i(choose_randomly([5,6]),0)
		[0,1,0,0]: # east only
			return Vector2i(choose_randomly([9,10]),0)
		[1,0,0,0]: # south only
			return Vector2i(choose_randomly([13,14]),0)
			
		_: # otherwise skip drawing
			return Vector2i(-1,-1)

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
				Globals.TILE_WATER:					
					Globals.world_map.set_cell(
						Globals.LAYER_TERRAIN,
						Vector2i(x, y),
						2,
						choose_tile(Vector2i(x, y)), # choose tile based on surrounding tiles
						0
					)	
				Globals.TILE_TERRAIN:
					Globals.world_map.set_cell(
						Globals.LAYER_TERRAIN,
						Vector2i(x, y),
						2,
						choose_forest_tile(Vector2i(x,y)),
						0
					)
				Globals.TILE_FOREST:
					Globals.world_map.set_cell(
						Globals.LAYER_TERRAIN,
						Vector2i(x, y),
						2,
						Vector2i(5,1),
						choose_randomly([0,1,2,3])
					)		
				_:  #default
					pass
					

# Fill water tiles, surrounded in 3-4 sides by land, with land.
# Do it recursively with limit of n recursions!
func smooth_land_features() -> void:
	# TODO for testing avoid map borders to make it simpler to implement			
	for y in range(1, Globals.map_image_size.y-1):
		for x in range(1, Globals.map_image_size.x-1):
			if map_tile_data[y][x] != Globals.TILE_WATER:
				continue
				
			smooth_recursively(Vector2i(x, y))

func smooth_recursively(pos:Vector2i) -> void:
	# now we are supposed to be inspecting a tile with land
	# 1 = water 0 = land
	var surrounding_tiles:Array = []

	# determine which directions have land around the tile
	for dir in directions:
		if map_tile_data[pos.y+dir.y][pos.x+dir.x] == Globals.TILE_TERRAIN:
			surrounding_tiles.append(Globals.TILE_TERRAIN)
		elif map_tile_data[pos.y+dir.y][pos.x+dir.x] == Globals.TILE_WATER:
			surrounding_tiles.append(Globals.TILE_WATER)	

	match surrounding_tiles:
		[1,1,1,0]: #west
			map_tile_data[pos.y][pos.x] = Globals.TILE_TERRAIN	
			pos.x -= 1
		[1,1,0,1]: #north
			map_tile_data[pos.y][pos.x] = Globals.TILE_TERRAIN	
			pos.y -= 1
		[1,0,1,1]: #east
			map_tile_data[pos.y][pos.x] = Globals.TILE_TERRAIN	
			pos.x += 1
		[0,1,1,1]: #south
			map_tile_data[pos.y][pos.x] = Globals.TILE_TERRAIN	
			pos.y += 1
		_:
			return 		
		
	smooth_recursively(pos)

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
