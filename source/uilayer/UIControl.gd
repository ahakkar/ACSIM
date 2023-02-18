class_name UIControl
extends Control

# var view = get_node("../View")

signal construction_button_pressed(button_name, button_type)
signal infolayer_button_pressed(button_type)
#@onready var node_minimap:Minimap
@onready var node_debuginfo:DebugInfo

var amount_of_chunks:int = 0
var size_of_chunk_removal_queue:int = 0


# name, position
var buttons = {
	"button_residental": [Vector2(0,0), "R"],
	"button_commercial": [Vector2(50,0), "C"],
	"button_industrial": [Vector2(100,00), "I"],
	"button_roads": [Vector2(0,50), "Rd"],
	"button_demolish": [Vector2(50,50), "Dm"],
	"button_services": [Vector2(100,50), "Sv"],		
	"button_social": [Vector2(150,50), "So"],	
	"button_infolayer_parcels": [Vector2(200,50), "Prc"],	
}

func _on_chunk_handler_chunk_stats(chunks, removal_queue):
	self.amount_of_chunks = chunks
	self.size_of_chunk_removal_queue = removal_queue


# Called when the node enters the scene tree for the first time.
func set_ready():
	create_buttons()	
	##node_minimap = Minimap.new()
	node_debuginfo = find_child("DebugInfo")
	node_debuginfo.set_ready()
	

# sends signals which View catches and places selected type of buildings
func _on_button_residental_pressed():
	emit_signal("construction_button_pressed", Globals.TYPE_RESIDENTIAL, 0)
	
	
func _on_button_commercial_pressed():
	emit_signal("construction_button_pressed", Globals.TYPE_COMMERCIAL, 0)


func _on_button_industrial_pressed():
	emit_signal("construction_button_pressed", Globals.TYPE_INDUSTRIAL, 0)


func _on_button_roads_pressed():
	emit_signal("construction_button_pressed", Globals.TYPE_ROADS, 0)


func _on_button_demolish_pressed():
	emit_signal("construction_button_pressed", Globals.TYPE_DEMOLISH, 0)
	

func _on_button_services_pressed():
	emit_signal("construction_button_pressed", Globals.TYPE_SERVICES, 0)


func _on_button_social_pressed():
	emit_signal("construction_button_pressed", Globals.TYPE_SOCIAL, 0)
	

func _on_button_infolayer_parcels_pressed():
	emit_signal("infolayer_button_pressed", Globals.INFOLAYER_PARCELS)	


func _on_main_worldgen_ready():
	self.set_process(true)

	
# defines construction toolbar buttons	
func create_buttons():
	for button in buttons:		
		var values = buttons[button]	
		var node_path = get_node(Globals.CONSTRUCTION_PANEL_NODE + "/" + str(button))
		
		if(!node_path):
			var errmsg = Globals.ERROR_BUTTON_NOT_FOUND % button
			push_error(errmsg)		
		
		node_path.set_size(Globals.GUI_BUILD_BUTTON_SIZE)
		node_path.set_position(values[0])
		node_path.set_anchor(SIDE_TOP, anchor_top)
		node_path.set_text(values[1])
		node_path.show()
		


