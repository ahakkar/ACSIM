class_name World
extends TileMap

var has_placeable_building: bool = false
var building
var building_type: String
var scene

func _init():
	Globals.world_map = self

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
	#var building_properties = get_building_properties()	
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
	
func place_building_to_map():
	var building_properties = get_building_properties()
	var tile_on_mouse = local_to_map(get_global_mouse_position())
	
	if !Globals.are_coords_valid(
		tile_on_mouse.y,
		Vector2i(0, Globals.map_image_size.y),
		Globals.ERROR_TILE_Y_COORDS_OUT_OF_BOUNDS
	):
		return false
	elif !Globals.are_coords_valid(
		tile_on_mouse.x,
		Vector2i(0, Globals.map_image_size.x),
		Globals.ERROR_TILE_X_COORDS_OUT_OF_BOUNDS
	):
		return false	

	set_cell(Globals.LAYER_BUILDINGS, tile_on_mouse, building_properties[0], building_properties[1], 0)
	
