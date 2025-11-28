class_name Mushroom

extends WeedEnemy

func get_animation() -> String:
	return get_dir()

func _on_hit() -> void:
	# Retaliate!
	if randi() % 2 == 0:
		call_deferred("shoot")
