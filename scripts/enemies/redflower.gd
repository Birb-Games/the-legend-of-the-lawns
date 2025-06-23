extends Area2D

@onready var player: Player = $/root/Main/Player
@export var bullet_scene: PackedScene

const MAX_HEALTH: int = 4
var health: int = MAX_HEALTH
const SHOOT_COOLDOWN: float = 4.5
var shoot_timer: float = 0.0
const SHOOT_RANGE: float = 112.0
const BULLET_DAMAGE: int = 6
const BULLET_SPEED: float = 80.0
var inside_lawnmower: bool = false
const LAWNMOWER_DAMAGE_COOLDOWN: float = 1.0
var lawnmower_damage_timer: float = 0.0

func explode() -> void:
	var offset = randf() * 2.0 * PI
	for i in range(5):
		var angle = offset + i * 2.0 * PI / 5.0
		var dir = Vector2(cos(angle), sin(angle))
		var bullet = bullet_scene.instantiate()
		bullet.position = $BulletSpawnPoint.global_position + dir * 4.0
		bullet.dir = dir
		$/root/Main/Lawn.add_child(bullet)
	queue_free()

func shoot() -> void:
	var dir = (player.get_sprite_pos() - $BulletSpawnPoint.global_position).normalized()
	# Shoot 3 bullets at once
	for i in range(-1, 2):
		var angle = dir.angle() + PI / 3.0 * i
		var bullet = bullet_scene.instantiate()
		bullet.global_position = $BulletSpawnPoint.global_position
		bullet.damage_amt = BULLET_DAMAGE
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
