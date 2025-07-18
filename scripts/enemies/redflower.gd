extends FlowerEnemy

@export var bullet_scene: PackedScene

func shoot() -> void:
	if !$/root/Main.lawn_loaded:
		return

	if player.health <= 0:
		return
	
	var dir = (player.get_sprite_pos() - $BulletSpawnPoint.global_position).normalized()
	# Shoot 3 bullets at once
	for i in range(-1, 2):
		var angle = dir.angle() + PI / 3.0 * i
		var bullet = bullet_scene.instantiate()
		bullet.global_position = $BulletSpawnPoint.global_position
		bullet.damage_amt = bullet_damage
		bullet.speed = bullet_speed
		bullet.dir = Vector2(cos(angle), sin(angle))
		$/root/Main/Lawn.add_child(bullet)

func _process(delta: float) -> void:
	update(delta, $BulletSpawnPoint.global_position)
	
	if dead():
		explode(bullet_scene, 5, $BulletSpawnPoint.global_position)

func _on_area_entered(area: Area2D) -> void:
	if area is PlayerBullet:
		area.explode()
		health -= 1
		health = max(health, 0)
		stun()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("lawnmower"):
		inside_lawnmower = true

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("lawnmower"):
		inside_lawnmower = false
