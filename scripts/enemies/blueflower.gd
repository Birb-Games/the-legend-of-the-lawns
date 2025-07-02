extends FlowerEnemy

@export var thorn_bullet: PackedScene
@export var spore_bullet: PackedScene

func rand_bullet() -> Node:
	if randi() % 3 == 0:
		return spore_bullet.instantiate()
	return thorn_bullet.instantiate()

func shoot() -> void:
	if player.health <= 0:
		return
	
	var offset = randf() * 2.0 * PI
	# Shoot 6 bullets at once
	for i in range(0, 6):
		var angle = offset + i * 2.0 * PI / 6.0
		var bullet = rand_bullet()
		bullet.global_position = $BulletSpawnPoint.global_position
		bullet.speed = bullet_speed
		bullet.dir = Vector2(cos(angle), sin(angle))
		$/root/Main/Lawn.add_child(bullet)

func _process(delta: float) -> void:
	update(delta, $BulletSpawnPoint.global_position)
	
	if dead():
		explode(spore_bullet, 8, $BulletSpawnPoint.global_position)

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
