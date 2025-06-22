extends Area2D

@onready var player: Player = $/root/Main/Player

const BULLET_COOLDOWN: float = 3.5
const MAX_SHOOT_DISTANCE: float = 128.0

@export var bullet_scene: PackedScene
var shoot_timer: float = BULLET_COOLDOWN

const MAX_HEALTH: int = 16
var health: int = MAX_HEALTH

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

func shoot() -> void:
	var bullet = bullet_scene.instantiate()
	var angle = (player.position - global_position).angle()
	var dir = Vector2(cos(angle), sin(angle))
	bullet.position = $BulletSpawnPoint.global_position
	bullet.dir = dir
	$/root/Main/Lawn.add_child(bullet)

func explode() -> void:
	var offset = randf() * 2.0 * PI
	for i in range(3):
		var angle = offset + i * 2.0 * PI / 3.0
		var dir = Vector2(cos(angle), sin(angle))
		var bullet = bullet_scene.instantiate()
		bullet.position = $BulletSpawnPoint.global_position + dir * 4.0
		bullet.dir = dir
		$/root/Main/Lawn.add_child(bullet)
		shoot_timer = BULLET_COOLDOWN
	queue_free()

func _process(delta: float) -> void:
	if health <= 0:
		explode()
		return
	
	$AnimatedSprite2D.animation = get_dir()
	
	$Healthbar.update_bar(health, MAX_HEALTH)
	
	shoot_timer -= delta
	
	var dist = (global_position - player.position).length()
	if shoot_timer < 0.0 and dist < MAX_SHOOT_DISTANCE and player.health > 0:
		shoot()
		shoot_timer = BULLET_COOLDOWN

func _on_area_entered(area: Area2D) -> void:
	if area is PlayerBullet:
		if randi() % 2 == 0:
			call_deferred("shoot")
		health -= 1
		health = max(health, 0)
		area.explode()
