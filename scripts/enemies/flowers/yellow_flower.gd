extends FlowerEnemy

func shoot() -> void:
	var dir = (player.get_sprite_pos() - $BulletSpawnPoint.global_position).normalized()
	shoot_bullet(bullet_scene, dir.angle())
