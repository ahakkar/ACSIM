class_name MainMenu
extends Control

signal button_pressed(button_name)

# Connect main menu to Main game

#func _process(delta):
#	print("aaa")


func set_ready():
	self.connect("button_pressed", self.get_parent()._on_mainmenu_button_pressed, CONNECT_PERSIST)
	self.find_child("Menu_ResumeGame").disabled = true
	

func _on_menu_new_game_pressed():
	emit_signal("button_pressed", Globals.MAINMENU_NEW_GAME)


func _on_menu_load_game_pressed():
	emit_signal("button_pressed", Globals.MAINMENU_LOAD_GAME)


func _on_menu_resume_game_pressed():
	emit_signal("button_pressed", Globals.MAINMENU_RESUME_GAME)


func _on_menu_options_pressed():
	emit_signal("button_pressed", Globals.MAINMENU_OPTIONS)


func _on_menu_credits_pressed():
	emit_signal("button_pressed", Globals.MAINMENU_CREDITS)


func _on_menu_exit_game_pressed():
	emit_signal("button_pressed", Globals.MAINMENU_QUIT_GAME)

	
