extends MobileEnemy

class_name HelperRabbit

static var helper_rabbit_scene: PackedScene = preload("uid://oihbb1ggds2j")

@export var blood_particles_scene: PackedScene
var change_dir_timer: float = 0.0
const CHANGE_DIR_INTERVAL: float = 0.1
const SHOOT_RANGE: float = 200.0
@onready var default_speed: float = speed
var idle_timer: float = 0.0
@onready var time_until_idle: float = randf_range(2.0, 4.0)

func in_shooting_range() -> bool:
	return true

func _ready() -> void:
	super._ready()
	$AnimatedSprite2D.animation = "spawn"

func calculate_velocity() -> Vector2:
	if idle_timer > 0.0:
		return Vector2.ZERO
	return super.calculate_velocity()

func get_animation() -> String:
	if spawn_timer > 0.1:
		return "spawn"
	if velocity.length() == 0.0:
		return "idle"
	return "running"

func explode() -> void:
	play_death_sound()
	var blood_particles: GPUParticles2D = blood_particles_scene.instantiate()
	blood_particles.global_position = $AnimatedSprite2D.global_position
	$/root/Main/Lawn.add_child(blood_particles)
	queue_free()

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
	bullet.speed += speed
	lawn.add_child(bullet)

func _process(delta: float) -> void:
	speed = min(player.speed - 8.0, default_speed)
	super._process(delta)

	$ContactDamageZone.disabled = true
	# Set direction of rabbit
	change_dir_timer -= delta
	if change_dir_timer < 0.0:
		set_sprite_dir()
		change_dir_timer = CHANGE_DIR_INTERVAL
	
	if spawn_timer <= 0.0:
		if idle_timer <= 0.0 and time_until_idle > 0.0:
			time_until_idle -= delta
		if time_until_idle <= 0.0:
			idle_timer = randf_range(0.5, 2.0)
			time_until_idle = randf_range(2.0, 4.0)
		if idle_timer > 0.0:
			idle_timer -= delta

func _on_bullet_hitbox_area_entered(body: Node2D) -> void:
	# Get damaged by enemy bullets
	if body is EnemyBullet:
		if !body.active():
			return
		if body.is_in_group("player_immune"):
			return
		damage(body.damage_amt)
		body.explode()
		return
	super._on_bullet_hitbox_area_entered(body)
