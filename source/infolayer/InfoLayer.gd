class_name InfoLayer
extends Node2D

var draw_mode:int

func _ready():
	#no layer disible by default
	draw_mode = Globals.INFLAYER_LAYERS_HIDDEN


func _draw():
	# pass == not implemented (yet)
	match draw_mode:
		Globals.INFOLAYER_PARCELS:
			draw_parcels()
		Globals.INFOLAYER_LAND_VALUE:pass
		Globals.INFOLAYER_ZONETYPES:pass
		Globals.INFOLAYER_TRAFFIC:pass
		Globals.INFOLAYER_NOISE:pass
		Globals.INFOLAYER_POLLUTION:pass
		Globals.INFOLAYER_GARBAGE:pass
		Globals.INFOLAYER_HAPPINESS:pass
		Globals.INFOLAYER_EDUCATION:pass
		Globals.INFOLAYER_CRIME:pass
		Globals.INFOLAYER_FIRE:pass
		Globals.INFOLAYER_HEAT:pass
		Globals.INFOLAYER_WATER:pass
		Globals.INFOLAYER_SNOW:pass
		Globals.INFOLAYER_DISTRICTS:pass
		_: #default
			push_error("InfoLayer: invalid draw mode '%s' specified!" % draw_mode)
		

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	self.position = Vector2(0,0)
	

func draw_parcels() -> void:
	for y in Globals.map_size/64:
		for x in Globals.map_size/16:
			if Globals.map_parcel_data[y][x] != null:				
				var p = Globals.map_parcel_data[y][x]
				
				# draw solid rect for non-city ownned parcels
				if Globals.map_parcel_data[y][x].owner != Globals.PARCEL_CITY:					
					# Rect2 = start x, start y, width, height
					draw_rect(Rect2(
						p.start.y*Globals.TILE_SIZE_Y,
						p.start.x*Globals.TILE_SIZE_X,
						p.size.x*Globals.TILE_SIZE_X, 
						p.size.y*Globals.TILE_SIZE_Y),
						Globals.INFOLAYER_PARCEL_FILL, true)	
				# draw borders for every parcel
				draw_rect(Rect2(
					p.start.y*Globals.TILE_SIZE_Y,
					p.start.x*Globals.TILE_SIZE_X,
					p.size.x*Globals.TILE_SIZE_X, 
					p.size.y*Globals.TILE_SIZE_Y), 
					Globals.INFOLAYER_PARCEL_BORDER, false, 4.0)
	
	
func get_draw_mode() -> int:
	return self.draw_mode
	

func set_draw_mode(mode:int) -> void:
	# change draw mode and redraw if it is not used
	self.draw_mode = mode
	if self.draw_mode >= 0:
		queue_redraw()
	


