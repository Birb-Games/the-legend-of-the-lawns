extends Area2D

class_name Drone

@export var bullet_scene: PackedScene
@export var explosion_scene: PackedScene
@onready var player: Player = $/root/Main/Player
@onready var lawn: Lawn = get_node_or_null("/root/Main/Lawn")
@onready var speed_factor: float = randf_range(0.55, 0.75)
var rotation_speed: float = 0.0
const SHOOT_RANGE: float = 300.0
const SHOOT_COOLDOWN: float = 2.0
var shoot_timer: float = SHOOT_COOLDOWN
const MAX_HEALTH: int = 10
var health: int = MAX_HEALTH
var pause_timer: float = 0.0
var time_until_next_pause: float = randf_range(2.0, 4.0)

func _ready() -> void:
	$Healthbar.hide()

func get_speed() -> float:
	return speed_factor * player.speed

# Shoot bullets
func shoot() -> void:
	if lawn == null:
		return
	
	# Attempt to target the closest enemy
	var closest_pos: Vector2 = Vector2.ZERO
	var closest_dist: float = 0.0
	var first_time: bool = true
	# Target weeds
	for weed_path: NodePath in lawn.weeds:
		var weed: WeedEnemy = get_node_or_null(weed_path)
		if weed == null:
			continue
		# Ignore weeds that are still spawning in
		if weed.scale.x < weed.target_scale:
			continue
		if first_time:
			first_time = false
			closest_pos = weed.global_position
			closest_dist = (weed.global_position - global_position).length()
			continue
		var dist = (weed.global_position - global_position).length()
		if dist < closest_dist:
			closest_dist = dist
			closest_pos = weed.global_position

	# Target mobile enemies
	for enemy in lawn.get_node("MobileEnemies").get_children():
		# Do not target other helper rabbits, evil gnomes, and killer rabbits
		if enemy is HelperRabbit or enemy is EvilGnome or enemy is KillerRabbit:
			continue
		if first_time:
			first_time = false
			closest_pos = enemy.global_position
			closest_dist = (enemy.global_position - global_position).length()
			continue
		var dist = (enemy.global_position - global_position).length()
		if dist < closest_dist:
			closest_dist = dist
			closest_pos = enemy.global_position

	if closest_dist > SHOOT_RANGE:
		return

	if first_time:
		return
	if bullet_scene == null:
		return
	var spawn_point: Node2D = get_node_or_null("BulletSpawnPoint")
	if spawn_point == null:
		return
	var bullet: EnemyBullet = bullet_scene.instantiate()
	var angle = (closest_pos - global_position).angle()
	var dir = Vector2(cos(angle), sin(angle))
	bullet.position = spawn_point.global_position + dir * 4.0
	bullet.dir = dir
	bullet.speed += get_speed()
	lawn.add_child(bullet)
	$Shoot.play()

func explode() -> void:
	var explosion: Explosion = explosion_scene.instantiate()
	explosion.global_position = $AnimatedSprite2D.global_position
	explosion.damage = 20
	explosion.can_damage_mobile = true
	explosion.can_damage_plants = true
	explosion.scale *= 0.3
	Sfx.play_at_pos(global_position, "explosion", lawn)
	lawn.add_child(explosion)
	queue_free()

func _process(delta: float) -> void:
	if health <= 0:
		explode()
		return

	$Healthbar.update_bar(health, MAX_HEALTH)

	shoot_timer -= delta
	if shoot_timer <= 0.0:
		shoot()
		shoot_timer = SHOOT_COOLDOWN

	var diff: Vector2 = player.global_position - global_position
	
	# Set the rotation speed
	if rotation_speed == 0.0 and diff.length() < 24.0:
		rotation_speed = randf_range(20.0, 30.0)
		if randi() % 2 == 0:
			rotation_speed *= -1.0
	elif diff.length() >= 24.0:
		rotation_speed = 0.0

	# Rotate around the player if the drone is close to the player
	if diff.length() < 16.0:
		if diff.length() > 8.0:	
			diff = diff.normalized()
			position += Vector2(diff.y, -diff.x) * delta * rotation_speed
		return
	
	# Follow the player
	diff = diff.normalized()
	if pause_timer <= 0.0:
		position += diff * delta * get_speed()

	if time_until_next_pause > 0.0:
		time_until_next_pause -= delta
		if time_until_next_pause <= 0.0:
			pause_timer = randf_range(0.5, 1.0)
	if pause_timer > 0.0 and time_until_next_pause <= 0.0:
		pause_timer -= delta
		if pause_timer <= 0.0:
			time_until_next_pause = randf_range(2.0, 6.0)

func _on_area_entered(area: Area2D) -> void:
	if area is PlayerBullet:
		if !area.active():
			return
		health -= area.damage
		area.explode()
	elif area is EnemyBullet:
		if !area.active():
			return
		if area.is_in_group("player_immune"):
			return
		health -= area.damage_amt
		area.explode()
