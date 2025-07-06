extends Area2D

@onready var player: Player = $/root/Main/Player

const BULLET_COOLDOWN: float = 4.5
const MAX_SHOOT_DISTANCE: float = 96.0

@export var bullet_scene: PackedScene
var shoot_timer: float = 0.0

const MAX_HEALTH: int = 10
var health: int = MAX_HEALTH
# Whether the enemy is engaged in fighting the player (the player shot at the enemy)
var engaged: bool = false

func player_in_range() -> bool:
	var dist = (global_position - player.position).length()
	if engaged:
		return dist < MAX_SHOOT_DISTANCE * 2.0
	return dist < MAX_SHOOT_DISTANCE

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

var target_scale: float
func _ready() -> void:
	$Healthbar.hide()

	if !$/root/Main.lawn_loaded:
		return

	target_scale = scale.x
	scale = Vector2.ZERO

func _process(delta: float) -> void:
	if !$/root/Main.lawn_loaded:
		return

	if scale.x < target_scale:
		scale.x += 2.0 * delta
		scale.x = min(scale.x, target_scale)
		scale.y = scale.x
		return
	
	if health <= 0:
		explode()
		return
	
	shoot_timer -= delta
	
	$Healthbar.update_bar(health, MAX_HEALTH)
	
	if shoot_timer < 0.0 and player_in_range() and player.health > 0:
		var bullet = bullet_scene.instantiate()
		# Some inaccuracy
		var rand_angle = randf() * PI / 3.0 - PI / 6.0
		var angle = (player.position - global_position).angle() + rand_angle
		var dir = Vector2(cos(angle), sin(angle))
		bullet.position = $BulletSpawnPoint.global_position
		bullet.dir = dir
		$/root/Main/Lawn.add_child(bullet)
		shoot_timer = BULLET_COOLDOWN

func _on_area_entered(area: Area2D) -> void:
	if scale.x < target_scale:
		return
	
	if area is PlayerBullet:
		engaged = true
		area.explode()
		health -= 1
		health = max(health, 0)
