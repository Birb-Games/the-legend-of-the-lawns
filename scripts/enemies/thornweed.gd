extends Area2D

@onready var player = $/root/Main/Player

const BULLET_COOLDOWN: float = 2.5
const MAX_SHOOT_DISTANCE: float = 112.0

@export var bullet_scene: PackedScene
var shoot_timer: float = BULLET_COOLDOWN

const MAX_HEALTH: int = 20
var health: int = MAX_HEALTH

func get_animation() -> String:
	var diff = player.get_sprite_pos() - global_position
	var norm = diff.normalized()
	
	if abs(norm.x) > abs(norm.y):
		if norm.x < 0.0:
			return "left"
		else:
			return "right"
	else:
		return "default"

func shoot() -> void:
	# Shoot 3 bullets
	for i in range(-1, 2):
		var bullet = bullet_scene.instantiate()
		var angle = (player.position - global_position).angle() + float(i) * PI / 6.0
		var dir = Vector2(cos(angle), sin(angle))
		bullet.position = $BulletSpawnPoint.global_position
		bullet.dir = dir
		$/root/Main/Lawn.add_child(bullet)

func explode() -> void:
	var offset = randf() * 2.0 * PI
	for i in range(8):
		var angle = offset + i * 2.0 * PI / 8.0
		var dir = Vector2(cos(angle), sin(angle))
		var bullet = bullet_scene.instantiate()
		bullet.position = $BulletSpawnPoint.global_position + dir * 4.0
		bullet.dir = dir
		$/root/Main/Lawn.add_child(bullet)
		shoot_timer = BULLET_COOLDOWN
	queue_free()

var target_scale: float
func _ready() -> void:
	$Healthbar.hide()
	target_scale = scale.x
	scale = Vector2.ZERO

func _process(delta: float) -> void:
	if scale.x < target_scale:
		scale.x += 2.0 * delta
		scale.x = min(scale.x, target_scale)
		scale.y = scale.x
		return
	
	if health <= 0:
		explode()
		return
	
	$AnimatedSprite2D.animation = get_animation()
	
	$Healthbar.update_bar(health, MAX_HEALTH)
	
	shoot_timer -= delta
	
	var dist = (global_position - player.position).length()
	if shoot_timer < 0.0 and dist < MAX_SHOOT_DISTANCE and player.health > 0:
		shoot()
		shoot_timer = BULLET_COOLDOWN

func _on_area_entered(area: Area2D) -> void:
	if scale.x < target_scale:
		return
	
	if area is PlayerBullet:
		if randi() % 3 == 0:
			call_deferred("shoot")
		area.explode()
		health -= 1
		health = max(health, 0)
