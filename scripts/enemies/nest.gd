# A 'nest' spawns enemies continuously if the player is too close

extends Area2D

class_name Nest

@export var to_spawn: PackedScene
@export var explosion_scene: PackedScene
@export var min_spawn_time: float = 5.0
@export var max_spawn_time: float = 12.0
@export var initial_spawn_delay: float = 2.0
@export var max_player_dist: float = 160.0
# In tile units
@export var min_dist: float = 2.0
@export var max_dist: float = 5.0
@export var min_count: int = 1
@export var max_count: int = 3
@export var spawn_probability: float = 1.0
@export var retaliate_probability: float = 0.2
@export var max_health: int = 30
@export var explosion_size: float = 0.75
@export var explosion_color: Color
@onready var health: int = max_health
@onready var spawn_timer: float = initial_spawn_delay
@onready var player: Player = $/root/Main/Player

func _ready() -> void:
	$Healthbar.hide()

func player_in_range() -> bool:
	return (player.global_position - global_position).length() < max_player_dist

func explode() -> void:
	var lawn: Lawn = get_node_or_null("/root/Main/Lawn")
	var explosion: GPUParticles2D = explosion_scene.instantiate()
	explosion.global_position = $Sprite2D.global_position
	explosion.scale *= 0.5
	explosion.modulate = explosion_color
	lawn.add_child(explosion)
	queue_free()

func _process(delta: float) -> void:
	$Healthbar.update_bar(health, max_health)

	if health <= 0:
		explode()
		return

	if player.health <= 0:
		return

	if player_in_range():
		spawn_timer -= delta
	
	if spawn_timer <= 0.0:
		spawn_timer = randf_range(min_spawn_time, max_spawn_time)
		var count: int = randi_range(min_count, max_count)
		if randf() < spawn_probability:
			var lawn: Lawn = get_node_or_null("/root/Main/Lawn")
			for i in range(count):
				Spawning.try_spawning_around_point(
					lawn,
					lawn.get_node("MobileEnemies"),
					global_position,
					to_spawn,
					min_dist,
					max_dist,
					2
				)

func _on_area_entered(area: Area2D) -> void:
	if area is PlayerBullet:
		area.explode()
		health -= 1
		health = max(health, 0)
		# Spawn enemies in retaliation
		if randf() < retaliate_probability and health > 0:
			spawn_timer = 0.0
