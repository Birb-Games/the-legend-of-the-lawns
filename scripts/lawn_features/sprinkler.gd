extends Area2D

@export var bullet_scene: PackedScene
var shots_left: int = 0
var cooldown: float = 0.0
var shoot_cooldown_time: float = 0.0
const SHOOT_INTERVAL: float = 0.5
var shot_rotation: float = 0.0
@onready var default_scale: Vector2 = scale

func _process(delta: float) -> void:
	if shots_left <= 0:
		cooldown = max(cooldown - delta, 0.0)
		return
	shoot_cooldown_time = max(shoot_cooldown_time - delta, 0.0)
	scale = default_scale * (1.125 - pow(shoot_cooldown_time / SHOOT_INTERVAL - 0.5, 2.0) * 0.5)	
	if shoot_cooldown_time <= 0.0:
		shoot_cooldown_time = SHOOT_INTERVAL
		shots_left -= 1

		var lawn: Lawn = $/root/Main/Lawn
		var count: int = randi_range(4, 6)
		for i in range(count):
			var bullet: PlayerBullet = bullet_scene.instantiate()
			var angle: float = 2.0 * PI / float(count) * i + shot_rotation
			bullet.dir = Vector2(cos(angle), sin(angle))
			bullet.global_position = $BulletSpawnPoint.global_position + bullet.dir * 4.0
			bullet.can_hit_player = true
			bullet.can_activate_sprinkler = false
			bullet.lifetime = 0.75
			lawn.add_child(bullet)

		shot_rotation = randf_range(0.0, 2.0 * PI)

func _on_area_entered(area: Area2D) -> void:
	if area is PlayerBullet:	
		if !area.can_activate_sprinkler:
			return
		area.explode()
		if cooldown > 0.0:
			return
		shots_left += randi_range(4, 7)
		shoot_cooldown_time = 0.0
		shot_rotation = randf_range(0.0, 2.0 * PI)
		cooldown = 5.0
