extends Control

# var view = get_node("../View")

signal button_pressed(button_name)

var BUTTON_SIZE = Vector2i(50,50)

# name, position
var buttons = {
	"button_residental": [Vector2(0,0), "R"],
	"button_commercial": [Vector2(50,0), "C"],
	"button_industrial": [Vector2(100,00), "I"],
	"button_roads": [Vector2(0,50), "Rd"],
	"button_demolish": [Vector2(50,50), "Dm"],
	"button_services": [Vector2(100,50), "Sv"],		
	"button_social": [Vector2(150,50), "So"],	
}

# Called when the node enters the scene tree for the first time.
func _ready():
	adjust_construction_panel()
	$ConstructionPanel.set_size(Vector2(500, 120))
	create_buttons()	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
	
func adjust_construction_panel():
	$ConstructionPanel.set_size(Vector2i(500, 120))
	$ConstructionPanel.set_position(Vector2i(0, -200))

# defines construction toolbar buttons	
func create_buttons():
	for button in buttons:		
		var values = buttons[button]	
		var node_path = get_node("ConstructionPanel/" + str(button))
		
		if(!node_path):
			push_error("Error: Button '" + button + "' not found when trying to set it's properties in Control.gd!")		
		
		node_path.set_size(BUTTON_SIZE)
		node_path.set_position(values[0])
		node_path.set_anchor(SIDE_TOP, anchor_top)
		node_path.set_text(values[1])
		node_path.show()

# sends signals which View catches and places selected type of buildings
func _on_button_residental_pressed():
	emit_signal("button_pressed", Globals.TYPE_RESIDENTIAL)
	
func _on_button_commercial_pressed():
	emit_signal("button_pressed", Globals.TYPE_COMMERCIAL)

func _on_button_industrial_pressed():
	emit_signal("button_pressed", Globals.TYPE_INDUSTRIAL)

func _on_button_roads_pressed():
	emit_signal("button_pressed", Globals.TYPE_ROADS)

func _on_button_demolish_pressed():
	emit_signal("button_pressed", Globals.TYPE_DEMOLISH)

func _on_button_services_pressed():
	emit_signal("button_pressed", Globals.TYPE_SERVICES)

func _on_button_social_pressed():
	emit_signal("button_pressed", Globals.TYPE_SOCIAL)
