class_name Minimap
extends Node

@onready var minimap_texture:ImageTexture = null
@onready var sprite:Sprite2D

# Called when the node enters the scene tree for the first time.
func _ready():
	minimap_texture = ImageTexture.new()	
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
	
	
func _on_main_worldgen_ready():
	print("test")
	self.generate_minimap()
	self.set_minimap()
	

func generate_minimap() -> void:
	var image = Image.new()
	print(Globals.map_size)
	image = Image.create(Globals.map_size, Globals.map_size, false, Image.FORMAT_RGB8)
	image.resize(Globals.map_size, Globals.map_size)
	for y in Globals.map_size:
		for x in Globals.map_size:
			var color:Color
			
			match Globals.map_terrain_data[y][x]:
				Globals.TILE_WATER:
					color = Color(0,0,255)
				Globals.TILE_TERRAIN:
					color = Color(148,113,71)
				Globals.TILE_FOREST:
					color = Color(0,255,0)
				_: #default
					color = Color(255,0,255)
						
			image.set_pixel(x, y, color)
			
	minimap_texture = ImageTexture.create_from_image(image)	

	
func set_minimap() -> void:
	sprite = self.get_child(1)
	sprite.texture = minimap_texture
	sprite.set_scale(Vector2i(2,2))
	sprite.set_position(Vector2(0, 0))



