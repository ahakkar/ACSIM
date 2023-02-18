# https://github.com/dfloer/SC2k-docs

class_name Main
extends Node

var bus:EventBus


func _ready() -> void:
	pause_game()
	bus = find_child("EventBus")
	bus.set_ready()	


func pause_game() -> void:
	get_tree().paused = true

	
func unpause_game() -> void:
	get_tree().paused = false
	

func quit_game():
	get_tree().get_root().propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
	get_tree().quit()



