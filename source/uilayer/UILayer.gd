class_name UILayer
extends CanvasLayer

@onready var node_minimap:Minimap


func _ready() -> void:
	node_minimap = find_child("Minimap")
	
	
func set_ready() -> void:
	node_minimap.set_ready()

	
