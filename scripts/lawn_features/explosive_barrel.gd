extends Node2D

class_name ExplosiveBarrel

@export var explosion_scene: PackedScene
@export var fire_scene: PackedScene
@onready var health: int = randi_range(3, 5)
@onready var default_scale: Vector2 = scale
var pulse: float = 0.0

func explode() -> void:	
	var lawn: Lawn = get_node_or_null("/root/Main/Lawn")
	if lawn:
		var camera: GameCamera = $/root/Main/Player/Camera2D
		camera.add_trauma(0.75)

		var explosion: Explosion = explosion_scene.instantiate()
		explosion.scale *= 0.4
		explosion.can_damage_plants = true
		explosion.can_damage_mobile = true
		explosion.damage = 60
		explosion.global_position = $Sprite2D.global_position
		lawn.add_child(explosion)

		# Add fire
		var fire: Fire = fire_scene.instantiate()
		fire.global_position = global_position
		fire.lifetime += 2.0
		lawn.add_child(fire)
		var count: int = randi_range(4, 6)
		for i in range(count):
			var dist: float = randf_range(1.0, 3.0)
			var angle: float = randf_range(0.0, 2.0 * PI)
			var dir: Vector2 = Vector2(cos(angle), sin(angle))
			var fire_position: Vector2 = global_position + dist * dir * lawn.tile_size
			var tile_x: int = int(floor(fire_position.x / lawn.tile_size.x))
			var tile_y: int = int(floor(fire_position.y / lawn.tile_size.y))
			var tile = lawn.get_tile(tile_x, tile_y)
			if !LawnGenerationUtilities.is_grass(tile) and !LawnGenerationUtilities.is_cut_grass(tile):
				continue
			if !(Vector2i(tile_x, tile_y) in lawn.valid_spawn_tiles):
				continue
			fire = fire_scene.instantiate()
			fire.global_position = fire_position
			lawn.add_child(fire)
	queue_free()

func _process(delta: float) -> void:
	if health <= 0:
		explode()
		return
	var pulse_scale: float = (0.25 - pow(pulse - 0.5, 2)) * 0.4 + 1.0
	scale = Vector2(pulse_scale * default_scale.x, pulse_scale * default_scale.y)
	if pulse >= 0.0:
		pulse = max(pulse - delta * 6.0, 0.0)

func _on_bullet_hitbox_area_entered(area: Area2D) -> void:
	if area is PlayerBullet:
		if !area.active():
			return
		area.explode()
		health -= 1
		pulse = 1.0
	elif area is EnemyBullet:
		if !area.active():
			return
		area.explode()
		health -= area.damage_amt
		pulse = 1.0
	elif area.get_parent() is Explosion:
		health = 0
