# Not to be confused with the "weed enemy" (weed.gd) - this is a template class
# that weed enemies inherit from as these types of enemies are fairly similar

class_name WeedEnemy

extends Area2D

@onready var player: Player = $/root/Main/Player

@export var bullet_scene: PackedScene
# How long it takes for the enemy to shoot a bullet (in seconds)
@export var bullet_cooldown: float = 5.0
# if the player is closer than this distance than the enemy will start shooting
# at the player, otherwise the enemy will ignore the player - if the player
# 'engaged' the enemy (shot at it) the enemy will still target the player at
# twice this distance
@export var max_shoot_distance: float = 100.0
# The number of bullets the enemy fires out upon death
@export var explosion_bullet_count: int = 5
@export var max_health: int = 10
@export var boss: bool = false
@export var grow_delay: float = 0.0

@onready var health: int = max_health 
@onready var shoot_timer: float = bullet_cooldown

# Emitted whenever the enemy is hit by a bullet
signal hit

# Whether the enemy is engaged in fighting the player (the player shot at the enemy)
var engaged: bool = false

# Enemies have a growing animation when they are first spawned:
# they start at a scale of 0 and then grow to have scale `target_scale`.
@onready var target_scale: float = scale.x

func _ready() -> void:
	$Healthbar.hide()

	if !$/root/Main.lawn_loaded:
		return

	var lawn: Lawn = get_node_or_null("/root/Main/Lawn")
	if lawn:
		lawn.total_weeds += 1

	# Add some screenshake to the camera
	var camera: GameCamera = $/root/Main/Player/Camera2D
	if boss:
		camera.add_trauma(1.0)

	scale = Vector2.ZERO

func player_in_range() -> bool:
	var dist = (global_position - player.position).length()
	if engaged:
		return dist < max_shoot_distance 
	return dist < max_shoot_distance * 2.0

# Upon death, an enemy might explode into a group of bullets that the player will
# have to avoid
func explode() -> void:
	var offset = randf() * 2.0 * PI
	for i in range(explosion_bullet_count):
		var angle = offset + i * 2.0 * PI / float(explosion_bullet_count)
		var dir = Vector2(cos(angle), sin(angle))
		var bullet = bullet_scene.instantiate()
		bullet.position = $BulletSpawnPoint.global_position + dir * 4.0
		bullet.dir = dir
		$/root/Main/Lawn.add_child(bullet)
	var lawn: Lawn = get_node_or_null("/root/Main/Lawn")
	if lawn:
		lawn.weeds_killed += 1
	queue_free()

# controls the growing animation for the enemy
# returns true if the animation is running, returns false otherwise
func update_growing_animation(delta: float) -> bool:
	if grow_delay > 0.0:
		grow_delay -= delta
		return true
	
	if scale.x < target_scale:
		scale.x += 2.0 * delta
		scale.x = min(scale.x, target_scale)
		scale.y = scale.x
		return true
	return false

func _on_area_entered(area: Area2D) -> void:
	if scale.x < target_scale:
		return
	
	if area is PlayerBullet:
		engaged = true
		hit.emit()
		area.explode()
		health -= 1
		health = max(health, 0)

func bullet_spawn_point() -> Vector2:
	return $BulletSpawnPoint.global_position

# Shoots a bullet in the direction of the player, it can also have an offset
# from being directly shot at the player.
func shoot_bullet(offset: float = 0.0) -> void:
	var bullet = bullet_scene.instantiate()
	var angle = (player.position - global_position).angle() + offset
	var dir = Vector2(cos(angle), sin(angle))
	bullet.position = $BulletSpawnPoint.global_position
	bullet.dir = dir
	$/root/Main/Lawn.add_child(bullet)

# Shoots bullets at the player, this function should be overridden if an enemy
# has a different shooting pattern
func shoot() -> void:
	shoot_bullet()

# Returns the general direction to the player as a string
func get_dir() -> String:
	var diff = player.get_sprite_pos() - global_position
	var norm = diff.normalized()
	
	if abs(norm.x) > abs(norm.y):
		if norm.x < 0.0:
			return "left"
		else:
			return "right"
	else:
		if norm.y < 0.0:
			return "up"
		else:
			return "down"

func update_shooting(delta: float) -> void:
	shoot_timer -= delta

	if player.health <= 0:
		return

	if shoot_timer >= 0.0:
		return

	if !player_in_range():
		return
	
	shoot()
	shoot_timer = bullet_cooldown

# Returns the animation that should be used for the enemy
func get_animation() -> String:
	return "default"

func _process(delta: float) -> void:
	if !$/root/Main.lawn_loaded:
		return

	if update_growing_animation(delta):
		return
	
	if health <= 0:
		explode()
		return

	$AnimatedSprite2D.animation = get_animation()		
	$Healthbar.update_bar(health, max_health)	
	update_shooting(delta)
