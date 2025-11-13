extends WeedEnemy

func get_animation() -> String:
	var diff = player.get_sprite_pos() - global_position
	var norm = diff.normalized()
	
	if abs(norm.x) > abs(norm.y):
		if norm.x < 0.0:
			return "left"
		else:
			return "right"
	else:
		return "default"

func shoot() -> void:
	# Shoot 3 bullets
	for i in range(-1, 2):
		var offset = float(i) * PI / 6.0
		shoot_bullet(offset)

func _on_hit() -> void:
	# Retaliate!
	if randi() % 3 == 0:
		call_deferred("shoot")
