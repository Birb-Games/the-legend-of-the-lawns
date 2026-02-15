extends Thornweed

# Constants for shrub weed enemy
const SPREAD: float = PI / 4.0
const INACCURACY_AMT: float = PI / 36.0

func shoot() -> void:
	var bullet_count = randi_range(1, 3)
	
	for i in range(bullet_count):
		var offset = SPREAD * (float(i) - (float(bullet_count) - 1.0) / 2.0)
		var inaccuracy = randf_range(-INACCURACY_AMT, INACCURACY_AMT)
		
		shoot_bullet(offset + inaccuracy)

func _on_hit() -> void:
	if randi() % 4 == 0:
		call_deferred("shoot")
