extends Thornweed

# Shoot only one bullet instead of 3
func shoot() -> void:
	# Some inaccuracy
	var rand_angle = randf() * PI / 4.0 - PI / 8.0
	shoot_bullet(rand_angle)

func _on_hit() -> void:
	# Retaliate!
	if randi() % 2 == 0:
		call_deferred("shoot")
