class_name Minimap
extends Control

signal set_camera_position(pos:Vector2)

@onready var minimap_texture:ImageTexture = null
@onready var sprite:Sprite2D
var is_mouse_inside_minimap:bool = false


# Called when the node enters the scene tree for the first time.
func _ready():
	self.minimap_texture = ImageTexture.new()
	

func _draw():
	#self.draw_rect(Rect2i(Vector2i(1,1), Vector2i(514,514)), Color(0,0,0), false, 2.0)
	pass
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if !is_mouse_inside_minimap:
		Globals.camera_marker.position = Vector2i(
			Globals.CAMERA_POSITION.x / 8,
			Globals.CAMERA_POSITION.y / 8,
			)

	
func _on_main_worldgen_ready():
	self.generate_minimap()
	self.set_minimap()
	self.setup_camera_marker()
	
	
func _on_mouse_entered():
	is_mouse_inside_minimap = true

func _on_mouse_exited():
	is_mouse_inside_minimap = false
	

func _unhandled_input(event) -> void:	
	if is_mouse_inside_minimap:
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
			Globals.camera_marker.position = get_local_mouse_position()
			emit_signal(
				"set_camera_position", 
				get_local_mouse_position() * 8
			)
	

func generate_minimap() -> void:	
	var image = Image.new()

	image = Image.create(Globals.map_size, Globals.map_size, false, Image.FORMAT_RGBAF)
	image.resize(Globals.map_size, Globals.map_size)
	for y in Globals.map_size:
		for x in Globals.map_size:
			var color:Color
			
			match Globals.map_terrain_data[y][x]:
				Globals.TILE_WATER:
					color = Globals.minimap_colors.get(Globals.TILE_WATER)
				Globals.TILE_TERRAIN:	
					color = Globals.minimap_colors.get(Globals.TILE_TERRAIN)
				Globals.TILE_FOREST:
					color = Globals.minimap_colors.get(Globals.TILE_FOREST)
				_: #default
					color = Globals.minimap_colors.get("default")
						
			image.set_pixel(x, y, color)
			
	minimap_texture = ImageTexture.create_from_image(image)		

	
func set_minimap() -> void:
	self.sprite = self.find_child("MinimapSprite")
	self.sprite.texture = minimap_texture
	
	# Assuming the area has a child CollisionShape2D with a RectangleShape resource
	var area_size = self.get_rect()
	area_size = area_size.size

	# The size of a sprite is determined from its texture
	var texture_size = sprite.texture.get_size()

	# Calculate which scale the sprite should have to match the size of the area
	var sx = area_size.x / texture_size.x
	var sy = area_size.y / texture_size.y

	sprite.scale = Vector2(sx, sy)
	
	
func setup_camera_marker() -> void:
	Globals.camera_marker = self.find_child("CameraMarker")
	



