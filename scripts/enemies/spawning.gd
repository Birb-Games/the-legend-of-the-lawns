class_name Spawning

class SpawnEntry:
	var name: String
	var weight: float

	func _init(entry_name: String, entry_weight: float) -> void:
		self.name = entry_name
		self.weight = entry_weight

static var weed_enemies: Dictionary = {
	"weed" : preload("uid://bhnk8apyedtit"),
	"mini_thornweed" : preload("uid://bpn14mbnmv14h"),
	"thornweed": preload("uid://fqhlxrgabgqv")
}

static var flower_enemies: Dictionary = {
	"yellow" : preload("uid://kai60sy8qsix"),
	"red" : preload("uid://cuwajf6p2vxkf"),
	"blue" : preload("uid://1fh3tiwr4hty")
}

static var weed_spawn_table: Dictionary = {
	"easy" : [ 
		SpawnEntry.new("weed", 3.0), 
		SpawnEntry.new("mini_thornweed", 2.0) 
	],

	"easy+" : [ 
		SpawnEntry.new("weed", 1.0), 
		SpawnEntry.new("mini_thornweed", 1.0) 
	],

	"medium" : [ 
		SpawnEntry.new("weed", 3.0),
		SpawnEntry.new("mini_thornweed", 3.0), 
		SpawnEntry.new("thornweed", 2.0) 
	],
}

static var weed_count_table: Dictionary = {
	"easy" : [ 3, 1 ],
	"easy+" : [ 3, 3, 1 ],
	"medium" : [ 3, 3, 1 ]
}

static var flower_spawn_table: Dictionary = {
	"easy" : [
		SpawnEntry.new("yellow", 1.0), 
	],
	
	"easy+" : [
		SpawnEntry.new("yellow", 1.0), 
	],

	"medium" : [
		SpawnEntry.new("yellow", 2.0), 
		SpawnEntry.new("red", 1.0)
	]
}

static var flower_count_table: Dictionary = {
	"easy" : [ 3, 1, 1 ],
	"easy+" : [ 3, 3, 1 ],
	"medium" : [ 3, 3, 1 ]
}

static func int_difficulty_to_string(difficulty: int) -> String:
	match difficulty:
		0:
			return "easy"
		1:
			return "easy+"
		2:
			return "medium"
		3:
			return "medium+"
		4:
			return "medium++"
		5:
			return "hard"
		6:
			return "hard+"
		7:
			return "hard++"
		8:
			return "hard+++"
	return ""

# Returns an index based on the array of weights
# Example: [ 2.0, 2.0, 1.0 ]
# Indices 0 and 1 would have probability 2.0 / (2.0 + 2.0 + 1.0) = 0.4
# While index 2 would have half the probability at 1.0 / (2.0 + 2.0 + 1.0) = 0.2
static func get_rand(spawn_entries: Array) -> String:
	var total: float = 0.0
	for entry in spawn_entries:
		total += entry.weight
	if total == 0.0:
		return ""
	
	var val = randf()
	var current_total = 0.0
	for i in range(len(spawn_entries)):
		var weight = spawn_entries[i].weight / total
		if val >= current_total and val < current_total + weight:
			return spawn_entries[i].name
		current_total += weight
	
	return spawn_entries[max(len(spawn_entries) - 1, 0)].name

static func get_weed_spawn_weights(difficulty: int) -> Array:
	return weed_spawn_table[int_difficulty_to_string(difficulty)]

static func get_rand_weed_count(difficulty: int) -> int:
	var counts: Array = weed_count_table[int_difficulty_to_string(difficulty)]
	if counts.is_empty():
		return 0
	return counts[randi() % len(counts)]

static func instantiate_weed(id: String) -> WeedEnemy:
	return weed_enemies[id].instantiate()

static func get_flower_spawn_weights(difficulty: int) -> Array:
	return flower_spawn_table[int_difficulty_to_string(difficulty)]

static func get_rand_flower_count(difficulty: int) -> int:
	var counts: Array = flower_count_table[int_difficulty_to_string(difficulty)]
	if counts.is_empty():
		return 0
	return counts[randi() % len(counts)]

static func instantiate_flower(id: String) -> FlowerEnemy:
	return flower_enemies[id].instantiate()

# Generates the enemy positions in a circle
# Parameters:
# The radius of the circle is calculated with the formula: radius = start + spacing * count
# Enemies are then generated at random positions in the distance between (radius - randomness) and radius
static func gen_enemy_positions_circle(
	count: int, 
	start: float, 
	spacing: float, 
	randomness: float
) -> Array:
	if count == 1:
		return [ Vector2(0.0, 0.0) ]

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
