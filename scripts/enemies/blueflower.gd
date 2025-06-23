extends Area2D

@onready var player: Player = $/root/Main/Player

const MAX_HEALTH: int = 6
var health: int = MAX_HEALTH
const SHOOT_COOLDOWN: float = 6.0
var shoot_timer: float = 0.0
const SHOOT_RANGE: float = 132.0
const BULLET_SPEED: float = 70.0
var inside_lawnmower: bool = false
const LAWNMOWER_DAMAGE_COOLDOWN: float = 1.0
var lawnmower_damage_timer: float = 0.0

@export var thorn_bullet: PackedScene
@export var spore_bullet: PackedScene

func rand_bullet() -> Node:
	if randi() % 3 == 0:
		return spore_bullet.instantiate()
	return thorn_bullet.instantiate()

func explode() -> void:
	var offset = randf() * 2.0 * PI
	for i in range(8):
		var angle = offset + i * 2.0 * PI / 8.0
		var dir = Vector2(cos(angle), sin(angle))
		var bullet = spore_bullet.instantiate()
		bullet.position = $BulletSpawnPoint.global_position + dir * 4.0
		bullet.dir = dir
		$/root/Main/Lawn.add_child(bullet)
	queue_free()

func shoot() -> void:
	var offset = randf() * 2.0 * PI
	# Shoot 3 bullets at once
	for i in range(0, 6):
		var angle = offset + i * 2.0 * PI / 6.0
		var bullet = rand_bullet()
		bullet.global_position = $BulletSpawnPoint.global_position
		bullet.speed = BULLET_SPEED
		bullet.dir = Vector2(cos(angle), sin(angle))
		$/root/Main/Lawn.add_child(bullet)

func _process(delta: float) -> void:
	$Healthbar.update_bar(health, MAX_HEALTH)
	
	shoot_timer -= delta
	var dist = (player.get_sprite_pos() - $BulletSpawnPoint.global_position).length()
	if dist < SHOOT_RANGE and shoot_timer <= 0.0:
		shoot()
		shoot_timer = SHOOT_COOLDOWN
	
	lawnmower_damage_timer -= delta
	if lawnmower_damage_timer <= 0.0 and inside_lawnmower:
		health -= 1
		health = max(health, 0)
		lawnmower_damage_timer = LAWNMOWER_DAMAGE_COOLDOWN
	
	if health <= 0:
		explode()

func _on_area_entered(area: Area2D) -> void:
	if area is PlayerBullet:
		area.explode()
		health -= 1
		health = max(health, 0)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("lawnmower"):
		inside_lawnmower = true

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("lawnmower"):
		inside_lawnmower = false
