extends Control

# var view = get_node("../View")

signal button_pressed(button_name)
@onready var debug_info = get_node(Globals.DEBUGINFO_NODE)

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
	create_buttons()	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	debug_info.set_text(
		str(get_viewport().get_mouse_position()) +"\n" + 
		"FPS " + str(Engine.get_frames_per_second()) + "\n" +
		"Zoom lvl: " + str(Globals.CAMERA_ZOOM_LEVEL) + "\n" + 
		"Chunk queue: " + str(Globals.chunk_queue.size()) + "\n" +
		"Camera pos: " + str(Globals.CAMERA_POSITION)
	)
	
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
