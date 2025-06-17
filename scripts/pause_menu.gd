extends ColorRect

func _on_no_pressed() -> void:
	hide()
	get_tree().paused = false

func _on_yes_pressed() -> void:
	hide()
	get_tree().paused = false
	# Return to neighborhood
	$/root/Main.return_to_neighborhood()
