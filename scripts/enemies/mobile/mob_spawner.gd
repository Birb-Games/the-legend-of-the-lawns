extends Node2D

@export var difficulty: int = 0
# Set this to 0 if you want a random number of enemies
@export var spawn_count: int = 0
var can_spawn: bool = true
# Set the enemies here if you want to change what types of enemies this spawner
# will spawn
@export var possible_enemies: Array[PackedScene]

func get_enemy_positions() -> Array:
	var positions = Spawning.gen_enemy_positions_circle(spawn_count, 16.0, 2.0, 8.0)
	for i in range(len(positions)):
		positions[i] += global_position
	return positions

func spawn() -> void:
	if !can_spawn:
		return

	var lawn: Node2D = get_node_or_null("/root/Main/Lawn/MobileEnemies")
	if lawn == null:
		return

	var positions: Array = []
	if !possible_enemies.is_empty():
		positions = get_enemy_positions()
		for i in range(spawn_count):
			var enemy: MobileEnemy = possible_enemies[randi() % len(possible_enemies)].instantiate()
			enemy.position = positions[i]
			lawn.call_deferred("add_child", enemy)
		return

	var weights = Spawning.get_mob_spawn_weights_random(difficulty)
	
	if weights.is_empty():
		return

	var enemy_id: String = Spawning.get_rand(weights)
	if spawn_count == 0:
		spawn_count = Spawning.get_rand_mob_count(difficulty, enemy_id)
	positions = get_enemy_positions()
	if enemy_id == "random":
		weights = Spawning.get_mob_spawn_weights(difficulty)
		for i in range(spawn_count):
			enemy_id = Spawning.get_rand(weights)
			if enemy_id.is_empty():
				continue
			var enemy: MobileEnemy = Spawning.instantiate_mob(enemy_id)
			enemy.position = positions[i]
			lawn.call_deferred("add_child", enemy)
	elif !enemy_id.is_empty():
		for i in range(spawn_count):
			var enemy: MobileEnemy = Spawning.instantiate_mob(enemy_id)
			enemy.position = positions[i]
			lawn.call_deferred("add_child", enemy)

func _ready() -> void:
	difficulty += $/root/Main/Lawn.difficulty

func _on_activation_zone_body_entered(body: Node2D) -> void:
	if body is Player:
		if body.lawn_mower_active():
			spawn()
			can_spawn = false
