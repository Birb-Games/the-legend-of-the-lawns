extends FlowerEnemy

func shoot() -> void:
	var dir = (player.get_sprite_pos() - $BulletSpawnPoint.global_position).normalized()
	# Shoot 3 bullets at once
	for i in range(-1, 2):
		shoot_bullet(bullet_scene, dir.angle() + PI / 3.0 * i)
