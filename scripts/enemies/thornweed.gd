extends Area2D

@onready var player = $/root/Main/Player

const BULLET_COOLDOWN: float = 2.5
const MAX_SHOOT_DISTANCE: float = 96.0

@export var bullet_scene: PackedScene
var shoot_timer: float = 0.0

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

func _process(delta: float) -> void:
	$AnimatedSprite2D.animation = get_animation()
	
	shoot_timer -= delta
	
	var dist = (global_position - player.position).length()
	if shoot_timer < 0.0 and dist < MAX_SHOOT_DISTANCE and player.health > 0:
		# Shoot 3 bullets
		for i in range(-1, 2):
			var bullet = bullet_scene.instantiate()
			var angle = (player.position - global_position).angle() + float(i) * PI / 15.0
			var dir = Vector2(cos(angle), sin(angle))
			bullet.position = $BulletSpawnPoint.global_position
			bullet.dir = dir
			$/root/Main/Lawn.add_child(bullet)
		shoot_timer = BULLET_COOLDOWN
