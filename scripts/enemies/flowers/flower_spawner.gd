extends Node2D

@export var difficulty: int = 0
# Set this to 0 if you want a random number of enemies
@export var spawn_count: int = 1
@export var spawn_probability: float = 1.0

# Spawns multiple types of enemies
func spawn() -> void:
	var positions = Spawning.gen_enemy_positions_circle(spawn_count, 16.0, 2.0, 8.0)

	var weights = Spawning.get_flower_spawn_weights(difficulty)
	
	if weights.is_empty():
		return

	for i in range(spawn_count):
		var enemy_id: String = Spawning.get_rand(weights)
		if enemy_id.is_empty():
			continue
		var enemy: FlowerEnemy = Spawning.instantiate_flower(enemy_id)
		enemy.position = positions[i]
		call_deferred("add_child", enemy)

func _ready() -> void:
	difficulty += $/root/Main/Lawn.difficulty

	if randf() > spawn_probability:
		return

	spawn()
