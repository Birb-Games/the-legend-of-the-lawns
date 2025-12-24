extends Control

func _on_no_pressed() -> void:
	hide()
	get_tree().paused = false

func _on_yes_pressed() -> void:
	hide()
	get_tree().paused = false
	# Return to neighborhood
	var main: Main = $/root/Main
	main.return_to_neighborhood()
	main.advance_day()
	main.save_progress()
	$/root/Main/Player/Lawnmower.hide()

