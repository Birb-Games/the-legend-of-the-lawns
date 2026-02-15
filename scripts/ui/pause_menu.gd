extends Control

func _on_no_pressed() -> void:
	var main: Main = $/root/Main
	main.play_sfx("Click")
	hide()
	get_tree().paused = false

func _on_yes_pressed() -> void:
	hide()
	get_tree().paused = false
	# Return to neighborhood
	var main: Main = $/root/Main
	main.play_sfx("Click")
	main.return_to_neighborhood()
	main.advance_day()
	main.save_progress()
	$/root/Main/Player/Lawnmower.hide()

func _on_main_menu_pressed() -> void:
	var main: Main = $/root/Main
	main.play_sfx("Click")
	$/root/Main/HUD/MainMenu.show()
	$/root/Main.reset()
	hide()

func _on_settings_pressed() -> void:
	var main: Main = $/root/Main
	main.play_sfx("Click")
	$/root/Main/HUD/MainMenu.show()
	$/root/Main/HUD/MainMenu/SettingsScreen.in_game = true
	$/root/Main/HUD/MainMenu/SettingsScreen.activate()
