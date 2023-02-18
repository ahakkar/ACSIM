class_name InfoLayer
extends Node2D

# displays various info layers of the game

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	



func _draw():
	for y in 16:
		for x in 64:
			draw_rect(Rect2(x*16*16, y*64*16, 16*16, 64*16), Color8(200,25,25,220), false, 4.0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	self.position = Vector2(0,0)
	


