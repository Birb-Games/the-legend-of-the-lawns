extends Node2D

var countdown: float = 2.5
@onready var timer: float = countdown
@onready var lawn: Lawn = $/root/Main/Lawn
@export var explosion_scene: PackedScene
@export var fire_scene: PackedScene

func _ready() -> void:
	scale = Vector2(0.0, 0.0)
	modulate.a = 0.0

func explode() -> void:
	var explosion: Explosion = explosion_scene.instantiate()
	explosion.global_position = global_position
	explosion.scale *= 0.7
	explosion.can_damage_mobile = true
	explosion.can_damage_plants = true
	explosion.damage = 80
	Sfx.play_at_pos(explosion.global_position, "explosion", lawn)
	lawn.add_child(explosion)

	# Add fire
	var fire: Fire = fire_scene.instantiate()
	fire.global_position = global_position
	fire.lifetime += 2.0
	lawn.add_child(fire)
	var count: int = randi_range(12, 16)
	for i in range(count):
		var dist: float = randf_range(1.0, 4.0)
		var angle: float = randf_range(0.0, 2.0 * PI)
		var dir: Vector2 = Vector2(cos(angle), sin(angle))
		var fire_position: Vector2 = global_position + dist * dir * lawn.tile_size
		var tile_x: int = int(floor(fire_position.x / lawn.tile_size.x))
		var tile_y: int = int(floor(fire_position.y / lawn.tile_size.y))
		if !(Vector2i(tile_x, tile_y) in lawn.valid_spawn_tiles):
			continue
		fire = fire_scene.instantiate()
		fire.global_position = fire_position
		lawn.add_child(fire)

func _process(delta: float) -> void:
	if timer < 0.0:
		explode()
		queue_free()
	timer -= delta
	scale.x = min(smoothstep(0.0, 1.0, clamp(1.25 * (0.8 - timer / countdown), 0.0, 1.0)), 1.0)
	scale.y = scale.x
	modulate.a = min(pow(1.0 - timer / countdown, 2.0) * 1.5, 1.5)
