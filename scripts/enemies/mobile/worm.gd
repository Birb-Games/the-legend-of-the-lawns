extends Area2D

@export var max_health: int = 128
@export var bullet_scene: PackedScene
@onready var health: int = max_health
@onready var timer: float = randf_range(5.0, 8.0)
var target_scale: float
var shrink: bool = false
var grow: bool = false
const SHOOT_COOLDOWN: float = 0.25
var shoot_timer: float  = SHOOT_COOLDOWN

func _ready() -> void:
	# Add some screenshake to the camera
	var camera: GameCamera = $/root/Main/Player/Camera2D
	camera.add_trauma(1.0)
	$AnimatedSprite2D.animation = "spawn"
	$Healthbar.hide()
	target_scale = scale.x
	scale = Vector2(0.0, 0.0)
	grow = true

func shoot_bullet(angle: float) -> void:
	var bullet: EnemyBullet = bullet_scene.instantiate()
	bullet.global_position = $BulletSpawnPoint.global_position
	bullet.dir = Vector2(cos(angle), sin(angle))
	$/root/Main/Lawn.add_child(bullet)

func shoot() -> void:
	var player: Player = $/root/Main/Player
	if player.health <= 0:
		return

	var bullet_count: int = randi_range(1, 5)
	for i in range(bullet_count):
		shoot_bullet(randf_range(0.0, 2.0 * PI))

# Attempts to randomly move the worm to somewhere near the player
# Returns if a spot was successfully found
func move() -> bool:
	var player: Player = $/root/Main/Player
	var lawn: Lawn = $/root/Main/Lawn
	var player_tile_x: int = int(floor(player.global_position.x / lawn.tile_size.x))
	var player_tile_y: int = int(floor(player.global_position.y / lawn.tile_size.y))
	var pos_x: int = player_tile_x + randi_range(-1, 1)
	var pos_y: int = player_tile_y + randi_range(-1, 1)

	# Ensure we have enough space
	for dx in range(-1, 1 + 1):
		var tile: Vector2i = lawn.get_tile(pos_x + dx, pos_y)
		if !LawnGenerationUtilities.is_grass(tile) and !LawnGenerationUtilities.is_cut_grass(tile):
			return false

	var x: float = (float(pos_x) + 0.5) * lawn.tile_size.x + randf_range(-0.25, 0.25)
	var y: float = (float(pos_y) + 0.5) * lawn.tile_size.y + randf_range(-0.25, 0.25)
	global_position = Vector2(x, y)	
	return true

func try_moving(tries: int) -> bool:
	for i in range(tries):
		if move():
			return true
	return false

func _process(delta: float) -> void:
	$ContactDamageZone.disabled = $AnimatedSprite2D.animation != "default" or !visible
	$CollisionShape2D.disabled = !visible
	if shrink:
		scale.x -= delta * 3.0
		scale.x = max(scale.x, 0.0)
		scale.y = scale.x
		if scale.x <= 0.01:
			hide()
			shrink = false
			if health <= 0:
				queue_free()
	if grow:
		scale.x += delta * 3.0
		scale.x = min(scale.x, target_scale)
		scale.y = scale.x
		if scale.x >= target_scale:
			grow = false
			$AnimatedSprite2D.play($AnimatedSprite2D.animation)

	if health <= 0:
		$Healthbar.hide()
		$AnimatedSprite2D.animation = "despawn"
		return

	if visible and $AnimatedSprite2D.animation == "default":
		shoot_timer -= delta
		if shoot_timer <= 0.0:
			shoot_timer = SHOOT_COOLDOWN
			shoot()

	$Healthbar.update_bar(health, max_health)
	if $AnimatedSprite2D.animation != "default":
		$Healthbar.hide()
	if $AnimatedSprite2D.animation != "spawn" and !shrink and !grow:
		timer -= delta
	if timer <= 0.0:
		match $AnimatedSprite2D.animation:
			"default":
				$AnimatedSprite2D.animation = "despawn"
				$AnimatedSprite2D.play("despawn")
				timer = randf_range(2.0, 12.0)
				$Healthbar.hide()
			"despawn":
				if try_moving(3):
					var player: Player = $/root/Main/Player
					var lawn: Lawn = $/root/Main/Lawn
					var camera: GameCamera = $/root/Main/Player/Camera2D
					var dist: float = (player.global_position - global_position).length() / lawn.tile_size.x
					camera.add_trauma(1.0 - min(dist / 16.0, 1.0))
					$AnimatedSprite2D.animation = "spawn"
					grow = true
					scale = Vector2(0.0, 0.0)
					timer = randf_range(5.0, 8.0)
					show()

func _on_animated_sprite_2d_animation_finished() -> void:
	if $AnimatedSprite2D.animation == "spawn":
		# Damage the player if they are standing too close
		var player: Player = $/root/Main/Player
		var dist: float = (player.global_position - global_position).length()
		if dist < 16.0:
			player.damage(40)
		$AnimatedSprite2D.animation = "default"
		$AnimatedSprite2D.play("default")
	elif $AnimatedSprite2D.animation == "despawn":
		shrink = true

func damage(amt: int) -> void:
	if $AnimatedSprite2D.animation != "default":
		return
	health -= amt
	health = max(health, 0)

func _on_area_entered(area: Area2D) -> void:
	if area is PlayerBullet:
		if !area.active():
			return
		area.explode()
		damage(1)
