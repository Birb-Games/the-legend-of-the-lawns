extends Area2D

@onready var player: Player = $/root/Main/Player

const BULLET_COOLDOWN: float = 3.5
const MAX_SHOOT_DISTANCE: float = 128.0

@export var bullet_scene: PackedScene
var shoot_timer: float = 0.0

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

func _process(delta: float) -> void:
	$AnimatedSprite2D.animation = get_dir()
	
	shoot_timer -= delta
	
	var dist = (global_position - player.position).length()
	if shoot_timer < 0.0 and dist < MAX_SHOOT_DISTANCE and player.health > 0:
		var bullet = bullet_scene.instantiate()
		var angle = (player.position - global_position).angle()
		var dir = Vector2(cos(angle), sin(angle))
		bullet.position = $BulletSpawnPoint.global_position
		bullet.dir = dir
		$/root/Main/Lawn.add_child(bullet)
		shoot_timer = BULLET_COOLDOWN
