extends Node2D

@export var enemies: Array[PackedScene]

@export var difficulty: int = 0
# Set this to 0 if you want a random number of enemies
# This should probably be a value <= 7
@export var spawn_count: int = 0
@export var spawn_probability: float = 1.0

# Spawns only one type of enemy
func spawn_single_type(count: int) -> void:
	var weights = Spawning.get_weights(Spawning.FLOWER_WEIGHT_TABLE, difficulty)
	var index = Spawning.get_rand_ind(weights)
	
	if count == 1:
		var enemy = enemies[index].instantiate()
		call_deferred("add_child", enemy)
		return
	
	var positions = Spawning.gen_enemy_positions_circle(count, 16.0, 2.0, 8.0)
	for i in range(count):
		var enemy = enemies[index].instantiate()
		enemy.position = positions[i]
		call_deferred("add_child", enemy)

# Spawns multiple types of enemies
func spawn_rand_types(count: int) -> void:
	var weights = Spawning.get_weights(Spawning.FLOWER_WEIGHT_TABLE, difficulty)
	var positions = Spawning.gen_enemy_positions_circle(count, 16.0, 2.0, 8.0)
	for i in range(count):
		var index = Spawning.get_rand_ind(weights)
		var enemy = enemies[index].instantiate()
		enemy.position = positions[i]
		call_deferred("add_child", enemy)

func _ready() -> void:
	if randf() > spawn_probability:
		return

	difficulty += $/root/Main/HUD.get_current_neighbor().difficulty
	
	var count = spawn_count
	if count == 0:
		count = Spawning.gen_rand_count(Spawning.FLOWER_COUNT_TABLE, difficulty)
	
	if count == 1:
		spawn_single_type(1)
		return
	
	if randi() % 2 == 0:
		spawn_single_type(count)
	else:
		spawn_rand_types(count)
