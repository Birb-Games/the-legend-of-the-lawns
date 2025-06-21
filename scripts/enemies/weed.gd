extends Area2D

@onready var player: Player = $/root/Main/Player

const BULLET_COOLDOWN: float = 4.5
const MAX_SHOOT_DISTANCE: float = 96.0

@export var bullet_scene: PackedScene
var shoot_timer: float = 0.0

func _process(delta: float) -> void:
	shoot_timer -= delta
	
	var dist = (global_position - player.position).length()
	if shoot_timer < 0.0 and dist < MAX_SHOOT_DISTANCE and player.health > 0:
		var bullet = bullet_scene.instantiate()
		# Some inaccuracy
		var rand_angle = randf() * PI / 3.0 - PI / 6.0
		var angle = (player.position - global_position).angle() + rand_angle
		var dir = Vector2(cos(angle), sin(angle))
		bullet.position = $BulletSpawnPoint.global_position
		bullet.dir = dir
		$/root/Main/Lawn.add_child(bullet)
		shoot_timer = BULLET_COOLDOWN
