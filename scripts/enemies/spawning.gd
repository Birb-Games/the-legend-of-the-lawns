class_name Spawning

const WEED_COUNT_TABLE: Array = [
	[ 3, 1, 1 ],
	[ 3, 3, 1 ],
	[ 5, 3, 1 ],
	[ 5, 3, 3, 3 ],
	[ 5, 3 ],
	[ 5, 5, 3 ],
	[ 7, 5, 3 ],
	[ 7, 5 ],
]

const FLOWER_COUNT_TABLE: Array = [
	[ 3, 1, 1 ],
	[ 3, 3, 1 ],
	[ 5, 3, 3 ],
	[ 5, 3 ],
]

const WEED_WEIGHT_TABLE: Array = [
	[ 6.0, 3.0, 1.0 ],
	[ 2.0, 1.0, 1.0 ],
	[ 1.0, 1.0, 1.0 ],
]

const FLOWER_WEIGHT_TABLE: Array = [
	[ 7.0, 2.0, 1.0 ],
	[ 3.0, 2.0, 1.0 ],
	[ 1.0, 1.0, 1.0 ]
]

# Count table must be an array of int arrays
static func get_counts(count_table: Array, ind: int) -> Array:
	if len(count_table) == 0:
		return [ 1 ]
	var i = clamp(ind, 0, len(count_table) - 1)
	return count_table[i]

# Count table must be an array of int arrays
static func gen_rand_count(count_table: Array, ind: int) -> int:
	var counts = get_counts(count_table, ind)
	if len(counts) == 0:
		return 1
	return counts[randi() % len(counts)]

# Weight table must be an array of float arrays
static func get_weights(weight_table: Array, ind: int) -> Array:
	if len(weight_table) == 0:
		return [ 1.0 ]
	var i = clamp(ind, 0, len(weight_table) - 1)
	return weight_table[i]

# Returns an index based on the array of weights
# Example: [ 2.0, 2.0, 1.0 ]
# Indices 0 and 1 would have probability 2.0 / (2.0 + 2.0 + 1.0) = 0.4
# While index 2 would have half the probability at 1.0 / (2.0 + 2.0 + 1.0) = 0.2
static func get_rand_ind(weights: Array) -> int:
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

# Generates the enemy positions in a circle
# Parameters:
# The radius of the circle is calculated with the formula: radius = start + spacing * count
# Enemies are then generated at random positions in the distance between (radius - randomness) and radius
static func gen_enemy_positions_circle(
	count: int, 
	start: float, 
	spacing: float, 
	randomness: float
) -> Array[Vector2]:
	var radius = start + float(count) * spacing
	var start_angle = randf() * PI * 2.0
	var positions: Array[Vector2] = []
	for i in range(count):
		var angle = start_angle + i * 2.0 * PI / count
		var dist = radius - randomness * randf()
		var x = cos(angle) * dist
		var y = sin(angle) * dist
		positions.append(Vector2(x, y))
	return positions
