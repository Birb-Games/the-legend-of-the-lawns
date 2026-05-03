extends EnemyBullet

@export var explosion_scene: PackedScene

func explode() -> void:
	var explosion: Explosion = explosion_scene.instantiate()
	explosion.modulate = Color8(128, 255, 32)
	explosion.modulate.a = 0.5
	explosion.scale *= 0.2
	explosion.can_damage_plants = true
	explosion.can_damage_mobile = true
	explosion.damage = 12
	explosion.global_position = global_position
	var lawn: Lawn = get_node_or_null("/root/Main/Lawn")
	if lawn:
		Sfx.play_at_pos(global_position, "explosion", lawn, 0.05)
		lawn.call_deferred("add_child", explosion)
	queue_free()
