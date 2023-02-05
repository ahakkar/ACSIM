extends Node2D

var gui
var building

# Called when the node enters the scene tree for the first time.
func _ready():	
	pass
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func _on_control_button_pressed(button_name):
	# create new building, in Building node it is attached to mouse cursor
	var scene = load(Globals.SCENE_PATH + "Building.tscn")
	building = scene.instantiate()	
	add_child(building)	
	
	#for _i in self.get_children():
	#	print(_i)
	
	# stop processing the sprite (fix it in place). no idea if it is a good idea yet..	
	
	
	# print(button_name + " button pressed in Control! :-0")

func _input(event):
	# places the building on cursor. a bad way!
	if Input.is_anything_pressed() and building != null:
		building.set_process(false)
		building = null
	# print(event.as_text())
