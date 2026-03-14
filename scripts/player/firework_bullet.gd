extends EnemyBullet

class_name FireworkBullet

@export var explosion_scene: PackedScene

func explode() -> void:
	var explosion: Explosion = explosion_scene.instantiate()
	explosion.global_position = global_position
	explosion.scale *= 0.25
	explosion.can_damage_mobile = true
	explosion.can_damage_plants = true
	explosion.damage = 8
	explosion.modulate = Color.RED
	var lawn: Lawn = get_node_or_null("/root/Main/Lawn")
	if lawn:
		lawn.call_deferred("add_child", explosion)
	super.explode()
