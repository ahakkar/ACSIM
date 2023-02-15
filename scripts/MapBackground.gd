extends Sprite2D

# sets the minimap texture as map background to avoid jarring transitions
func _on_minimap_set_map_background_texture(sprite):
	self.texture = sprite
	self.scale = Vector2(16, 16)	

