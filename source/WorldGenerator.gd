class_name WorldGenerator
extends RefCounted


# About biome generation with noise: https://www.redblobgames.com/maps/terrain-from-noise/
# Trees with Poisson Disc: http://devmag.org.za/2009/05/03/poisson-disk-sampling/


signal worldgenerator_function_called(message:String, runtime:float)

var image:Image = Image.new()	

var directions:Array = [
	Vector2i(0,1),	# south
	Vector2i(1,0),	# east
	Vector2i(0,-1), # north
	Vector2i(-1,0)  # west
	]
	
	
func are_coords_valid(value:int, bounds:Vector2i, errmsg:String) -> bool:
	if bounds.x > value or value > bounds.y:		
		errmsg = errmsg % [value, bounds.x, bounds.y]
		push_error(errmsg)
		return false
	
	return true
	
	
func choose_randomly(list_of_entries):
	return list_of_entries[randi() % list_of_entries.size()]
	

func choose_tile(tile:Vector2i, selected, surrounding) -> Array:
	var surrounding_tiles:Array = []
			
	# determine which directions have land around the tile
	for dir in directions:
		# avoid index out of bounds
		if (tile.y+dir.y >= Globals.map_size) or (tile.x+dir.x >= Globals.map_size):
			surrounding_tiles.append(surrounding)
		elif Globals.map_terrain_data[tile.y+dir.y][tile.x+dir.x] == surrounding:
			surrounding_tiles.append(surrounding)
		else:
			surrounding_tiles.append(selected)	
		
	# this is because a tile can have more than 1 option
	var selected_tile = Globals.td[surrounding].get(surrounding_tiles)
	var tile_coords:Vector2i
	
	if selected_tile == null:
		tile_coords = Globals.td[selected].get("default")[0]
	elif selected_tile.size() > 1:
		tile_coords = choose_randomly(selected_tile)
	else:
		tile_coords = selected_tile[0]
		
	return [tile_coords, 0 if selected_tile else choose_randomly([0,1,2,3])]
		
	
# Generates biomes, like forest and bog
func generate_biomes() -> void:
	# generate a new noisemap which should emulate forest-looking areas
	var fnl:FastNoiseLite = FastNoiseLite.new()
	fnl.noise_type = FastNoiseLite.TYPE_SIMPLEX
	fnl.seed = 69 #randi()
	fnl.frequency = 0.01
	fnl.fractal_type = FastNoiseLite.FRACTAL_FBM
	fnl.fractal_octaves = 7
	fnl.fractal_lacunarity = 1.671
	fnl.fractal_gain = 0.947
	
	var water_next_to_tile:bool = false

	for y in Globals.map_terrain_data.size():
		for x in Globals.map_terrain_data[y].size():		
				
			# replace non-water with biomes			
			if Globals.map_terrain_data[y][x] > 0:	
				water_next_to_tile = false
				
				# don't put forest next to water
				for dir in directions:
					if (y+dir.y >= Globals.map_size) or (x+dir.x >= Globals.map_size):
						continue
					if Globals.map_terrain_data[y+dir.y][x+dir.x] == Globals.TILE_WATER:
						water_next_to_tile = true
				
				# if there's no water next to a land tile, it can be replaced with forest
				if !water_next_to_tile:
					var noise_sample = fnl.get_noise_2d(x, y)
					if noise_sample < 0.1:
						Globals.map_terrain_data[y][x] = Globals.TILE_FOREST	
					# can add other tresholds here for other biomes


func generate_parcels() -> void:
	# divide the land area Cadastres / Parcels
	# TODO better solution, this is something my skills were able to handle at proto stage
	# should replace with a real/better algo when I am skilled enough to do it
	Globals.map_parcel_data.resize(Globals.map_size / Globals.PARCEL_HEIGHT)
	
	for y in Globals.map_size / Globals.PARCEL_HEIGHT:
		Globals.map_parcel_data[y].resize(Globals.map_size / Globals.PARCEL_WIDTH)		
		for x in Globals.map_size / Globals.PARCEL_WIDTH:
			# ignore parcels full fo water
			if !is_filled_with_water(Vector2i(x,y)):
				Globals.map_parcel_data[y][x] = Globals.Parcel.new()
				Globals.map_parcel_data[y][x].start = Vector2i(
					y * Globals.PARCEL_HEIGHT,
					x * Globals.PARCEL_WIDTH,
					)						
				Globals.map_parcel_data[y][x].size = Vector2i(
					Globals.PARCEL_WIDTH,
					Globals.PARCEL_HEIGHT,
					)
				Globals.map_parcel_data[y][x].owner = Globals.PARCEL_STATE
				
	
	# not used, but could be used later
	var total_parcels = Globals.map_size/Globals.PARCEL_WIDTH * Globals.map_size / Globals.PARCEL_HEIGHT	
	give_starting_parcels_for_city(total_parcels)


func generate_world(filename) -> bool:	
	# Try to load the image which we used to place water & ground to world map		
	image = load(filename)		
	if image == null:
		var errmsg:String = Globals.ERROR_FAILED_TO_LOAD_FILE
		push_error(errmsg % filename)
		return false
				
	if (image.get_size().x / image.get_size().y) != 1:
		push_error("Error: image size was invalid in world generator")
		return false
		
	var image_size:Vector2i = image.get_size()
	Globals.map_size = image_size.x
	
	if !validate_mapgen_params():
		push_error("Error: invalid mapgen size parameters in world generator")
		return false	
		
	# idx 0: message sent to GUI, 1: function call, 2: optional args
	var worldgen_calls:Array[Array] = [
		["Reading image data", "read_image_pixel_data"],
		["Smoothing water", "smooth_land_features", Globals.TILE_WATER],
		["Generating parcels", "generate_parcels"],
		["Generating biomes", "generate_biomes"],
		["Smoothing forests", "smooth_land_features", Globals.TILE_FOREST],
		["Precalculating tilemap tiles", "select_tilemap_tiles"],
		]
	
	# do this to send the generation stage and processing time to GUI
	var start:int;
	var end:int;
			
	for function in worldgen_calls:
		start = Time.get_ticks_usec()			
		if function.size() == 3:
			self.call(function[1], function[2])
		else:
			self.call(function[1])
		
		end = Time.get_ticks_usec()		
		emit_signal("worldgenerator_function_called", (end-start)/1000.0, function[0])

	return true


func give_starting_parcels_for_city(_amount:int) -> void:
	# gives a x*y parcel initial starting area for the player
	var p_x = Globals.map_size/Globals.PARCEL_WIDTH/2
	var p_y = Globals.map_size/Globals.PARCEL_HEIGHT/2
	
	for y in range(0, Globals.STARTING_AREA_HEIGHT_IN_PARCELS):
		for x in range(0, Globals.STARTING_AREA_WIDTH_IN_PARCELS):
			if Globals.map_parcel_data[p_y-y][p_x-x] != null:
				Globals.map_parcel_data[p_y-y][p_x-x].owner = Globals.PARCEL_CITY


# forests are not generated yet so can just compare water and terrain
func is_filled_with_water(coords:Vector2i) -> bool:
	#var terrain_tile_count:int = 0

#	0*64, 0*64 +64-1 = 0-63
#	1*64, 1*64 +63 = 64-127
#	2*64, 2*64 +63 = 128-191
#	3*64, 3*64 +63 = 192-255
	for y in range(
		coords.y*Globals.PARCEL_HEIGHT,
		coords.y*Globals.PARCEL_HEIGHT + Globals.PARCEL_HEIGHT-1
		):
		for x in range(
			coords.x*Globals.PARCEL_WIDTH,
			coords.x*Globals.PARCEL_WIDTH + Globals.PARCEL_WIDTH-1
			):
			if Globals.map_terrain_data[y][x] == Globals.TILE_TERRAIN:
				return false
				#terrain_tile_count += 1
		
	# parcel is ok if it has at least one land
	#if terrain_tile_count > 0:
	#	return false
	return true
		

func read_image_pixel_data() -> void:
	# initialize the array to have enough rows
	Globals.map_terrain_data.resize(Globals.map_size)
	Globals.map_tile_data.resize(Globals.map_size)
	
	for y in Globals.map_size:
		#initialize the row to have enough columns
		Globals.map_terrain_data[y].resize(Globals.map_size)
		Globals.map_tile_data[y].resize(Globals.map_size)		

		for x in Globals.map_size:
			if image.get_pixel(x, y) == Globals.WATER_TILE_COLOR_IN_MAP_FILE:
				Globals.map_terrain_data[y][x] = Globals.TILE_WATER
			else:
				Globals.map_terrain_data[y][x] = Globals.TILE_TERRAIN
				
			
func select_tilemap_tiles() -> void:
	for y in Globals.map_terrain_data.size():
		for x in Globals.map_terrain_data[y].size():
			# layer | position coords | tilemap id | coords of the tile at tilemap | alternative tile
			match Globals.map_terrain_data[y][x]:
				Globals.TILE_WATER:	 # water or shoreline
					Globals.map_tile_data[y][x] = choose_tile(Vector2i(x,y), Globals.TILE_WATER, Globals.TILE_TERRAIN)
						
				Globals.TILE_TERRAIN: #terrain or forest edge
					Globals.map_tile_data[y][x] = choose_tile(Vector2i(x,y), Globals.TILE_TERRAIN, Globals.TILE_FOREST)
					
				Globals.TILE_FOREST:		
					Globals.map_tile_data[y][x] = [Vector2i(5,1), choose_randomly([0,1,2,3])]
						
				_:  #default
					push_error("should be never here in worldgen!")
					pass
					

# Fill water tiles, surrounded in 3-4 sides by land, with land.
# Do it recursively with limit of n recursions!
func smooth_land_features(tile_type:int) -> void:
	# TODO for testing avoid map borders to make it simpler to implement			
	for y in range(1, Globals.map_size-1):
		for x in range(1, Globals.map_size-1):
			if Globals.map_terrain_data[y][x] != tile_type:
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
		# avoid out of bounds hack
		if (pos.y+dir.y >= Globals.map_size) or (pos.x+dir.x >= Globals.map_size):
			surrounding_tiles.append(comp)
		elif Globals.map_terrain_data[pos.y+dir.y][pos.x+dir.x] == comp:
			surrounding_tiles.append(comp)
		elif Globals.map_terrain_data[pos.y+dir.y][pos.x+dir.x] == selected:
			surrounding_tiles.append(selected)	

	match surrounding_tiles:
		[1,1,1,2]: #west
			Globals.map_terrain_data[pos.y][pos.x] = comp	
			pos.x -= 1
		[1,1,2,1]: #north
			Globals.map_terrain_data[pos.y][pos.x] = comp	
			pos.y -= 1
		[1,2,1,1]: #east
			Globals.map_terrain_data[pos.y][pos.x] = comp	
			pos.x += 1
		[2,1,1,1]: #south
			Globals.map_terrain_data[pos.y][pos.x] = comp	
			pos.y += 1
		[1,1,1,1]: # remove solo forests
			Globals.map_terrain_data[pos.y][pos.x] = comp	
			return
		_:
			return 		
		
	smooth_forest_recursively(pos, selected, comp)
	

func smooth_recursively(pos:Vector2i, selected:int, comp:int) -> void:
	# now we are supposed to be inspecting a tile with land
	var surrounding_tiles:Array = []

	# determine which directions have land around the tile
	for dir in directions:
		# avoid out of bounds hack
		if (pos.y+dir.y >= Globals.map_size) or (pos.x+dir.x >= Globals.map_size):
			surrounding_tiles.append(comp)
		elif Globals.map_terrain_data[pos.y+dir.y][pos.x+dir.x] == comp:
			surrounding_tiles.append(comp)
		elif Globals.map_terrain_data[pos.y+dir.y][pos.x+dir.x] == selected:
			surrounding_tiles.append(selected)	

	match surrounding_tiles:
		[1,1,1,0]: #west
			Globals.map_terrain_data[pos.y][pos.x] = comp	
			pos.x -= 1
		[1,1,0,1]: #north
			Globals.map_terrain_data[pos.y][pos.x] = comp	
			pos.y -= 1
		[1,0,1,1]: #east
			Globals.map_terrain_data[pos.y][pos.x] = comp	
			pos.x += 1
		[0,1,1,1]: #south
			Globals.map_terrain_data[pos.y][pos.x] = comp	
			pos.y += 1
		_:
			return 		
		
	smooth_recursively(pos, selected, comp)
	
	
func validate_mapgen_params() -> bool:
	if !are_coords_valid(
		Globals.map_size,
		Vector2i(Globals.MAP_MIN_HEIGHT, Globals.MAP_MAX_HEIGHT),
		Globals.ERROR_IMAGE_HEIGHT_INCORRECT):
		return false
		
	elif !are_coords_valid(
		Globals.map_size,
		Vector2i(Globals.MAP_MIN_WIDTH, Globals.MAP_MAX_WIDTH),
		Globals.ERROR_IMAGE_WIDTH_INCORRECT):
		return false
		
	return true
