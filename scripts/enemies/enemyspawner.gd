extends Node2D

@export var enemies: Array[PackedScene]
@export var difficulty: int = 0
@export var enemy_probability: float = 1.0
# Set this to 0 if you want a random number of enemies
# This should probably be a value <= 7
@export var spawn_count: int = 0

# Weights of enemy counts
func get_enemy_count() -> int:
	var counts = []
	match difficulty:
		0:
			counts = [ 3, 1, 1 ]
		1:
			counts = [ 3, 3, 1 ]
		2:
			counts = [ 5, 3, 1 ]
		3:
			counts = [ 5, 3, 3, 3 ]
		4:
			counts = [ 5, 3 ]
		5:
			counts = [ 5, 5, 3 ]
		6:
			counts = [ 7, 5, 3 ]
		_:
			counts = [ 7, 5 ]
	
	return counts[randi() % len(counts)]

# Doesn't have to add to 1.0, weighted proportionally
func get_enemy_weights() -> Array[float]:
	match difficulty:
		0:
			return [ 3.0, 1.0, 1.0 ]
		1:
			return [ 2.0, 1.0, 1.0 ]
		_:
			return [ 1.0, 1.0, 1.0 ]

func get_rand_enemy_ind(weights: Array[float]) -> int:
	var total = 0.0
	for w in weights:
		total += w
	if total == 0.0:
		return 0
	
	var val = randf()
	var current_total = 0.0
	for i in range(len(weights)):
		var weight = weights[i] / total
		if val >= current_total and val < current_total + weight:
			return i
		current_total += weight
	
	return max(len(weights) - 1, 0)

func gen_enemy_positions(count: int) -> Array[Vector2]:
	var radius = 32.0 + count * 4.0
	var start_angle = randf() * PI * 2.0
	var positions: Array[Vector2] = []
	for i in range(count):
		var angle = start_angle + i * 2.0 * PI / count
		var dist = radius - 20.0 * randf()
		var x = cos(angle) * dist
		var y = sin(angle) * dist
		positions.append(Vector2(x, y))
	return positions

# Spawns only one type of enemy
func spawn_single_type(count: int) -> void:
	var weights = get_enemy_weights()
	var index = get_rand_enemy_ind(weights)
	
	if count == 1:
		var enemy = enemies[index].instantiate()
		add_child(enemy)
		return
	
	var positions = gen_enemy_positions(count)
	for i in range(count):
		var enemy = enemies[index].instantiate()
		enemy.position = positions[i]
		add_child(enemy)

# Spawns multiple types of enemies
func spawn_rand_types(count: int) -> void:
	var weights = get_enemy_weights()
	
	var positions = gen_enemy_positions(count)
	for i in range(count):
		var index = get_rand_enemy_ind(weights)
		var enemy = enemies[index].instantiate()
		enemy.position = positions[i]
		add_child(enemy)

func _ready() -> void:
	if randf() > enemy_probability:
		return
	
	var enemy_count = spawn_count
	if enemy_count == 0:
		enemy_count = get_enemy_count()
	
	if enemy_count == 1:
		spawn_single_type(1)
		return
	
	if randi() % 4 == 0:
		spawn_single_type(enemy_count)
	else:
		spawn_rand_types(enemy_count)
