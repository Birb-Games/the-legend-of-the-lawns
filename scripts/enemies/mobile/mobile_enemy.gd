class_name MobileEnemy

extends CharacterBody2D

@onready var player: Player = $/root/Main/Player
@onready var lawn: Lawn = get_node_or_null("/root/Main/Lawn")
@export var speed: float = 40.0
@export var min_chase_distance: float = 10.0
@export var max_chase_distance: float = 200.0
@export var max_health: int = 10
@export var explosion_bullet_count: int = 5
@export var spawn_animation_time: float = 1.0
@export var bullet_scene: PackedScene
# How long it takes for the enemy to shoot a bullet (in seconds)
@export var bullet_cooldown: float = 1.0
@export var immune_to_friendly_fire: bool = false
@export var immune_to_fire: bool = false
@onready var shoot_timer: float = bullet_cooldown
@onready var health = max_health
var path: PackedVector2Array = []
var current_path_index: int = 0
const ARRIVE_DISTANCE: float = 8.0
var target_tile_pos: Vector2i
# Fire damage
var fire_collisions: Dictionary
var fire_damage_timer: float = 0.0
var FIRE_DAMAGE_INTERVAL: float = 0.75
var fire_time: float = 0.0
@onready var spawn_timer: float = spawn_animation_time

const UPDATE_PATH_INTERVAL: float = 0.25
var update_path_timer: float = UPDATE_PATH_INTERVAL

signal hit

func _ready() -> void:
	$Healthbar.hide()

# Returns the tile coordinates that this enemy is currently occupying
func get_tile_pos() -> Vector2i:
	return Vector2i(
		floor(global_position.x / lawn.tile_size.x),
		floor(global_position.y / lawn.tile_size.y)
	)

func update_path() -> void:
	target_tile_pos = player.get_tile_position()
	path = lawn.astar_grid.get_point_path(get_tile_pos(), player.get_tile_position())
	var offsets: Array[Vector2] = []
	for i in range(len(path)):
		path[i].x += lawn.tile_size.x / 2.0
		path[i].y += lawn.tile_size.y / 2.0
		if i == 0:
			offsets.push_back(Vector2(0.0, 0.0))
			continue
		var prev: Vector2 = path[i - 1]
		var offset: Vector2 = Vector2(path[i].x - prev.x, path[i].y - prev.y) * 0.6
		if offset.y < 0.0:
			offset.y += $CollisionShape2D.shape.get_rect().size.y / 2.0
		offsets.push_back(offset)
	for i in range(len(offsets)):
		path[i] += offsets[i]
	current_path_index = 0

func can_chase_player() -> bool:
	if player.health <= 0:
		return false
	var player_pos = player.global_position
	if player.lawn_mower_active():
		player_pos += player.get_lawn_mower_dir_offset()
	var player_dist = (player_pos - global_position).length()
	return player_dist <= max_chase_distance and player_dist >= min_chase_distance

func calculate_velocity() -> Vector2:
	if spawn_timer > 0.0:
		return Vector2.ZERO

	var vel: Vector2 = Vector2.ZERO

	if !can_chase_player():
		return Vector2.ZERO

	if lawn == null:
		return Vector2.ZERO	

	if current_path_index >= len(path):
		return Vector2.ZERO

	var dist: float = (path[current_path_index] - global_position).length()
	if dist < ARRIVE_DISTANCE or current_path_index == 0:
		current_path_index += 1
	if current_path_index >= len(path):
		return Vector2.ZERO

	var next_pos: Vector2 = path[current_path_index]
	vel = (next_pos - global_position).normalized() * speed

	return vel

func play_death_sound() -> void:
	Sfx.play_at_pos(global_position, "pop", $/root/Main/Lawn)

# Upon death, an enemy might explode into a group of bullets that the player will
# have to avoid
func explode() -> void:
	if randi() % 50 == 0:
		PowerUp.spawn($/root/Main/Lawn, global_position)
	play_death_sound()
	var offset = randf() * 2.0 * PI
	for i in range(explosion_bullet_count):
		var angle = offset + i * 2.0 * PI / float(explosion_bullet_count)
		var dir = Vector2(cos(angle), sin(angle))
		var bullet = bullet_scene.instantiate()
		bullet.position = $BulletSpawnPoint.global_position + dir
		bullet.dir = dir
		lawn.add_child(bullet)
	queue_free()

# Shoots a bullet in the direction of the player, it can also have an offset
# from being directly shot at the player.
func shoot_bullet(offset: float = 0.0) -> void:
	if bullet_scene == null:
		return
	var spawn_point: Node2D = get_node_or_null("BulletSpawnPoint")
	if spawn_point == null:
		return
	var bullet: EnemyBullet = bullet_scene.instantiate()
	var angle = (player.position - global_position).angle() + offset
	var dir = Vector2(cos(angle), sin(angle))
	bullet.position = spawn_point.global_position + dir * 4.0
	bullet.dir = dir
	bullet.speed += speed
	lawn.add_child(bullet)

# Shoots bullets at the player, this function should be overridden if an enemy
# has a different shooting pattern
func shoot() -> void:
	shoot_bullet()

func in_shooting_range() -> bool:
	return can_chase_player()

func update_shooting(delta: float) -> void:
	if bullet_cooldown < 0.0:
		return

	shoot_timer -= delta

	if player.health <= 0:
		return

	if shoot_timer >= 0.0:
		return

	if !in_shooting_range():
		return
	
	shoot()
	shoot_timer = bullet_cooldown

# Returns true if the path was updated
func handle_path_update(delta: float) -> bool:
	if player.get_tile_position() != target_tile_pos:
		update_path_timer -= delta
	else:
		update_path_timer = UPDATE_PATH_INTERVAL
	if update_path_timer <= 0.0:
		update_path_timer = UPDATE_PATH_INTERVAL
		update_path()
		return true
	return false

func take_fire_damage(delta: float) -> void:
	if immune_to_fire:
		return
	var fire_particles: Node2D = get_node_or_null("FireParticles")
	# Try to set the enemy on fire
	for fire_path: String in fire_collisions.keys():
		var fire = get_node_or_null(fire_path)
		# if the fire doesn't exist, ignore it
		if fire == null:
			continue
		if fire is Fire:
			# Make sure the fire is actually active
			if fire.lifetime <= 0.2:
				continue
			fire_time = 2.0
	if fire_time <= 0.0:
		if fire_particles:
			fire_particles.queue_free()
		return
	fire_time -= delta
	if fire_particles == null:
		add_child(Fire.fire_particles.instantiate())
	fire_damage_timer -= delta
	if fire_damage_timer <= 0.0:
		fire_damage_timer = FIRE_DAMAGE_INTERVAL
		damage(1)

func _process(delta: float) -> void:
	$ContactDamageZone.disabled = spawn_timer > 0.0
	if spawn_timer > 0.0:
		spawn_timer -= delta
		return

	$AnimatedSprite2D.animation = get_animation()
	if !$AnimatedSprite2D.is_playing():
		$AnimatedSprite2D.play($AnimatedSprite2D.animation)
	$Healthbar.update_bar(health, max_health)

	if health <= 0:
		explode()
		queue_free()
		return

	take_fire_damage(delta)
	if player.health <= 0.0:
		return
	
	handle_path_update(delta)	
	update_shooting(delta)

func _physics_process(_delta: float) -> void:
	velocity = calculate_velocity()
	move_and_slide()

func get_animation() -> String:
	return "default"

func set_dir_left() -> void:
	$AnimatedSprite2D.flip_h = true

func set_dir_right() -> void:
	$AnimatedSprite2D.flip_h = false

func set_sprite_dir() -> void:
	if player.global_position.x < global_position.x - 8.0:
		set_dir_left()
	elif player.global_position.x > global_position.x + 8.0:
		set_dir_right()

	var vel = calculate_velocity()
	if vel.length() > 0.0 and vel.normalized().dot(Vector2.LEFT) > 0.25:
		set_dir_left()
	elif vel.length() > 0.0 and vel.normalized().dot(Vector2.RIGHT) > 0.25:
		set_dir_right()

func damage(amt: int) -> void:
	if spawn_timer > 0.0:
		return

	hit.emit()
	health -= amt
	health = max(health, 0)

func _on_bullet_hitbox_area_entered(body: Node2D) -> void:
	if body is PlayerBullet:
		if !body.active():
			return
		body.explode()
		damage(body.damage)
	elif body is EnemyBullet:
		if !body.active():
			return
		if (!immune_to_friendly_fire and body.is_in_group("friendly_fire")) or body.is_in_group("target_all_mobile"):
			body.explode()
			damage(body.damage_amt)
	elif body is Fire:
		fire_collisions[body.get_path()] = true
	elif body.get_parent() is Explosion:
		if get_path() in body.get_parent().hit:
			return
		body.get_parent().hit[get_path()] = true
		damage(body.get_parent().calculate_damage(global_position))
	elif body is BoomShroom:
		body.explode_flag = true

func _on_bullet_hitbox_area_exited(body: Node2D) -> void:
	if body is Fire:
		fire_collisions.erase(body.get_path())
