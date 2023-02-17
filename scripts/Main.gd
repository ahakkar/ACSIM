# https://github.com/dfloer/SC2k-docs

class_name Main
extends Node2D


var bus:EventBus


func _init() -> void:	
#	DisplayServer.window_set_size(
#		#Vector2i(Globals.DEFAULT_X_RES, Globals.DEFAULT_Y_RES)
#		Vector2i(3800,2000)
#	)
	pass
	

func _ready() -> void:
	pause_game()
	bus = find_child("EventBus")
	bus.set_camera_position(Vector2(16*256/2, 16*256/2))


func pause_game() -> void:
	get_tree().paused = true

	
func unpause_game() -> void:
	get_tree().paused = false
	

func quit_game():
	get_tree().get_root().propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
	get_tree().quit()



