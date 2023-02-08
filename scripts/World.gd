extends TileMap

var building : bool = false
var building_type: String
var tilemap: Vector2i
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
		place_building_to_map()
	
	# cancel placement
	if event.is_action_pressed("cancel"):
		if building != false:
			pass
			

func place_building_to_map():
	# layer | position coords | tilemap id | coords of the tile at tilemap | alternative tile
		
	match building_type:
		Globals.TYPE_RESIDENTIAL:
			tilemap = Vector2i(0,0)
			set_cell(0, local_to_map(get_viewport().get_mouse_position()) , 0, tilemap, 0)
		Globals.TYPE_COMMERCIAL:
			tilemap = Vector2i(4,12)
			set_cell(0, local_to_map(get_viewport().get_mouse_position()) , 1, tilemap, 0)
		Globals.TYPE_INDUSTRIAL:
			tilemap = Vector2i(4,20)
			set_cell(0, local_to_map(get_viewport().get_mouse_position()) , 1, tilemap, 0)
		Globals.TYPE_ROADS:
			tilemap = Vector2i(14,2)
			set_cell(0, local_to_map(get_viewport().get_mouse_position()) , 1, tilemap, 0)
		Globals.TYPE_DEMOLISH:
			tilemap = Vector2i(4,4)
			set_cell(0, local_to_map(get_viewport().get_mouse_position()) , 1, tilemap, 0)
		Globals.TYPE_SERVICES:
			tilemap = Vector2i(4,8)
			set_cell(0, local_to_map(get_viewport().get_mouse_position()) , 1, tilemap, 0)
		Globals.TYPE_SOCIAL:
			tilemap = Vector2i(4,0)
			set_cell(0, local_to_map(get_viewport().get_mouse_position()) , 1, tilemap, 0)
		_:	#default
			tilemap = Vector2i(16,16)
			set_cell(0, local_to_map(get_viewport().get_mouse_position()) , 1, tilemap, 0)
			
	# set_cell(0, local_to_map(get_viewport().get_mouse_position()) , 1, tilemap, 0)
