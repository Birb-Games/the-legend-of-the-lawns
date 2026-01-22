# This is the class that flower enemies will inherit from

class_name FlowerEnemy

extends Area2D

@onready var player: Player = $/root/Main/Player

@export var max_health: int = 1
@export var shoot_cooldown: float = 1.0
@export var shoot_range: float = 112.0
@export var bullet_speed: float = 100.0
@export var stun_amt: float = 1.0
@export var bullet_damage: int = 1
@export var explosion_bullet_count: int = 5
@export var bullet_scene: PackedScene

@onready var health: int = max_health
var shoot_timer: float = 0.0
const LAWNMOWER_DAMAGE_COOLDOWN: float = 1.0
var lawnmower_damage_timer: float = 0.0
var stun_timer: float = 0.0

# Stuns the flower, this is triggered whenever the flower is hit by a bullet
# When the flower is stunned it can not attack
func stun() -> void:
	stun_timer += stun_amt
	stun_timer = max(stun_timer, stun_amt)

func update_stun_timer(delta: float) -> void:
	var stun_particles = get_node_or_null("StunParticles")
	var sprite = get_node_or_null("AnimatedSprite2D")

	# Ignore if no particles/animated sprite found
	if sprite == null or stun_particles == null:
		printerr("Flower enemy must have AnimatedSprite2D and StunParticles as children!")
		return

	if stun_timer > 0.0:
		stun_timer -= delta
		stun_particles.emitting = true
		stun_particles.show()
		sprite.animation = "stunned"
	else:
		stun_particles.emitting = false
		stun_particles.hide()
		sprite.animation = "default"

# Returns if the flower is stunned
func stunned() -> bool:
	return stun_timer > 0.0

# Returns if the flower is dead (health <= 0)
func dead() -> bool:
	return health <= 0

# The flower explodes upon death
func explode(bullet_template: PackedScene) -> void:
	Sfx.play_at_pos(global_position, "pop", $/root/Main/Lawn)
	var spawn = $BulletSpawnPoint.global_position
	var offset = randf() * 2.0 * PI
	for i in range(explosion_bullet_count):
		var angle = offset + i * 2.0 * PI / float(explosion_bullet_count)
		var dir = Vector2(cos(angle), sin(angle))
		var bullet = bullet_template.instantiate()
		bullet.position = spawn + dir * 4.0
		bullet.dir = dir
		$/root/Main/Lawn.add_child(bullet)
	$/root/Main/Lawn.flowers_destroyed += 1
	PenaltyParticle.emit_penalty($/root/Main/HUD.get_current_neighbor().flower_penalty, spawn, $/root/Main/Lawn)
	queue_free()

func inside_lawn_mower() -> bool:
	var dist: float
	var y_dist: float

	var lawn_mower: Lawnmower = get_node_or_null("/root/Main/Lawn/Lawnmower")
	if lawn_mower != null and lawn_mower.visible:
		var lawn_mower_rect: Rect2 = lawn_mower.rect()
		lawn_mower_rect.position = lawn_mower.global_position
		lawn_mower_rect.position.y += lawn_mower_rect.size.y / 4.0
		dist = global_position.distance_to(lawn_mower_rect.position)
		y_dist = lawn_mower_rect.position.y - global_position.y
		if dist < 8.0 and y_dist < 6.0:
			return true
	
	var player_lawn_mower_rect: Rect2 = player.get_lawn_mower_rect()
	player_lawn_mower_rect.position.y += player_lawn_mower_rect.size.y / 4.0
	dist = global_position.distance_to(player_lawn_mower_rect.position)
	y_dist = player_lawn_mower_rect.position.y - global_position.y
	if dist < 8.0 and y_dist < 6.0:
		var player_lawn_mower: Node2D = player.get_node_or_null("Lawnmower")
		if player_lawn_mower != null and player_lawn_mower.visible:
			return true
	
	return false

func apply_lawnmower_damage(delta: float) -> void:
	lawnmower_damage_timer -= delta
	if lawnmower_damage_timer <= 0.0 and inside_lawn_mower():
		health -= 1
		health = max(health, 0)
		lawnmower_damage_timer = LAWNMOWER_DAMAGE_COOLDOWN
		stun()

func can_shoot() -> bool:
	# Lawn is not loaded, do not shoot
	if !$/root/Main.lawn_loaded:
		return false

	# Player is dead, do not shoot
	if player.health <= 0:
		return false

	return true

func shoot_bullet(bullet_template: PackedScene, angle: float) -> void:
	var bullet = bullet_template.instantiate()
	bullet.global_position = $BulletSpawnPoint.global_position
	bullet.damage_amt = bullet_damage
	bullet.speed = bullet_speed
	bullet.dir = Vector2(cos(angle), sin(angle))
	$/root/Main/Lawn.add_child(bullet)

func shoot() -> void:
	pass

func update_shooting(delta: float) -> void:
	if !stunned():
		shoot_timer -= delta
	var spawn = $BulletSpawnPoint.global_position
	var dist = (player.get_sprite_pos() - spawn).length()
	if dist < shoot_range and shoot_timer <= 0.0 and !stunned():
		if can_shoot():
			shoot()
		shoot_timer = shoot_cooldown

func update(delta: float) -> void:
	# Update health bar
	var healthbar = get_node_or_null("Healthbar")
	if healthbar != null:
		healthbar.update_bar(health, max_health)

	update_stun_timer(delta)
	# Shoot bullets
	update_shooting(delta)
	apply_lawnmower_damage(delta)

func _process(delta: float) -> void:
	update(delta)
	
	if dead():
		explode(bullet_scene)

func _on_area_entered(area: Area2D) -> void:
	# Handle getting hit by a bullet
	if area is PlayerBullet:
		area.explode()
		health -= 1
		health = max(health, 0)
		stun()
