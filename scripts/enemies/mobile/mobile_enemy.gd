class_name MobileEnemy

extends CharacterBody2D

@onready var player: Player = $/root/Main/Player
@onready var lawn: Lawn = get_node_or_null("/root/Main/Lawn")
@export var speed: float = 40.0
@export var min_chase_distance: float = 10.0
@export var max_chase_distance: float = 200.0
@export var max_health: int = 10
@export var explosion_bullet_count: int = 5
@export var bullet_scene: PackedScene
# How long it takes for the enemy to shoot a bullet (in seconds)
@export var bullet_cooldown: float = 1.0
@onready var shoot_timer: float = bullet_cooldown
@onready var health = max_health
var path: PackedVector2Array = []
var current_path_index: int = 0
const ARRIVE_DISTANCE: float = 8.0
var current_player_tile_pos: Vector2i

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
	current_player_tile_pos = player.get_tile_position()
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

# Upon death, an enemy might explode into a group of bullets that the player will
# have to avoid
func explode() -> void:
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
	var bullet: EnemyBullet = bullet_scene.instantiate()
	var angle = (player.position - global_position).angle() + offset
	var dir = Vector2(cos(angle), sin(angle))
	bullet.position = $BulletSpawnPoint.global_position + dir * 4.0
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
	shoot_timer -= delta

	if player.health <= 0:
		return

	if shoot_timer >= 0.0:
		return

	if !in_shooting_range():
		return
	
	shoot()
	shoot_timer = bullet_cooldown

func _process(delta: float) -> void:
	$AnimatedSprite2D.animation = get_animation()	
	$Healthbar.update_bar(health, max_health)

	if health <= 0:
		explode()
		queue_free()
		return

	if player.health <= 0.0:
		return
	
	if player.get_tile_position() != current_player_tile_pos:
		update_path_timer -= delta
	else:
		update_path_timer = UPDATE_PATH_INTERVAL
	if update_path_timer <= 0.0:
		update_path_timer = UPDATE_PATH_INTERVAL
		update_path()
	
	update_shooting(delta)

func _physics_process(_delta: float) -> void:
	velocity = calculate_velocity()
	move_and_slide()

func get_animation() -> String:
	return "default"

func _on_bullet_hitbox_area_entered(body: Node2D) -> void:
	if body is PlayerBullet:
		hit.emit()
		body.explode()
		health -= 1
		health = max(health, 0)
