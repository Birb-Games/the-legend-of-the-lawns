class_name FlowerEnemy

extends Area2D

@onready var player: Player = $/root/Main/Player

@export var max_health: int = 1
@export var shoot_cooldown: float = 1.0
@export var shoot_range: float = 112.0
@export var bullet_speed: float = 100.0
@export var stun_amt: float = 1.0
@export var bullet_damage: int = 1

@onready var health: int = max_health
var shoot_timer: float = 0.0
var inside_lawnmower: bool = false
const LAWNMOWER_DAMAGE_COOLDOWN: float = 1.0
var lawnmower_damage_timer: float = 0.0
var stun_timer: float = 0.0

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

func stunned() -> bool:
	return stun_timer > 0.0

func dead() -> bool:
	return health <= 0.0

func explode(bullet_scene: PackedScene, count: int, spawn: Vector2) -> void:
	var offset = randf() * 2.0 * PI
	for i in range(count):
		var angle = offset + i * 2.0 * PI / float(count)
		var dir = Vector2(cos(angle), sin(angle))
		var bullet = bullet_scene.instantiate()
		bullet.position = spawn + dir * 4.0
		bullet.dir = dir
		$/root/Main/Lawn.add_child(bullet)
	$/root/Main/Lawn.flowers_destroyed += 1
	PenaltyParticle.emit_penalty($/root/Main/HUD.get_current_neighbor().flower_penalty, spawn, $/root/Main/Lawn)
	queue_free()

func apply_lawnmower_damage(delta: float) -> void:
	lawnmower_damage_timer -= delta
	if lawnmower_damage_timer <= 0.0 and inside_lawnmower:
		health -= 1
		health = max(health, 0)
		lawnmower_damage_timer = LAWNMOWER_DAMAGE_COOLDOWN
		stun()

func shoot() -> void:
	pass

func update_shooting(delta: float, spawn: Vector2) -> void:
	if !stunned():
		shoot_timer -= delta
	var dist = (player.get_sprite_pos() - spawn).length()
	if dist < shoot_range and shoot_timer <= 0.0 and !stunned():
		shoot()
		shoot_timer = shoot_cooldown

func update(delta: float, bullet_spawn_pos: Vector2):
	# Update health bar
	var healthbar = get_node_or_null("Healthbar")
	if healthbar != null:
		healthbar.update_bar(health, max_health)

	update_stun_timer(delta)
	# Shoot bullets
	update_shooting(delta, bullet_spawn_pos)
	apply_lawnmower_damage(delta)
