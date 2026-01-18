extends Control

func _on_button_pressed() -> void:
	var main: Main = $/root/Main	
	main.play_sfx("Click")
	hide()

