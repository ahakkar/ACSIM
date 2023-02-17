class_name MapBackground
extends Sprite2D

# sets the minimap texture as map background to avoid jarring transitions
func set_map_background_texture(sprite, scaling:Vector2) -> void:
	self.texture = sprite
	self.scale = scaling

