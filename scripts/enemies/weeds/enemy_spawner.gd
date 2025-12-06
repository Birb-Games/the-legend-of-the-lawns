extends Node2D

@export var difficulty: int = 0
# Set this to 0 if you want a random number of enemies
@export var spawn_count: int = 0
var can_spawn: bool = true
# Set the enemies here if you want to change what types of enemies this spawner
# will spawn
@export var possible_enemies: Array[PackedScene]
@export var trigger_upon_lawn_completion: bool = false

func spawn() -> void:
	if !can_spawn:
		return
	
	var positions = Spawning.gen_enemy_positions_circle(spawn_count, 16.0, 2.0, 8.0)

	if !possible_enemies.is_empty():
		for i in range(spawn_count):
			var enemy: WeedEnemy = possible_enemies[randi() % len(possible_enemies)].instantiate()
			enemy.position = positions[i]
			$Enemies.call_deferred("add_child", enemy)
		return

	var weights = Spawning.get_weed_spawn_weights(difficulty)
	
	if weights.is_empty():
		return

	for i in range(spawn_count):
		var enemy_id: String = Spawning.get_rand(weights)
		if enemy_id.is_empty():
			continue
		var enemy: WeedEnemy = Spawning.instantiate_weed(enemy_id)
		enemy.position = positions[i]
		$Enemies.call_deferred("add_child", enemy)

func _ready() -> void:
	difficulty += $/root/Main/Lawn.difficulty

	if spawn_count == 0:
		spawn_count = Spawning.get_rand_weed_count(difficulty)

func _process(_delta: float) -> void:
	var lawn: Lawn = get_node_or_null("/root/Main/Lawn")
	if lawn != null and trigger_upon_lawn_completion:
		if lawn.cut_grass_tiles == lawn.total_grass_tiles and can_spawn:
			spawn()
			can_spawn = false

func _on_activation_zone_body_entered(body: Node2D) -> void:
	if body is Player:
		if body.lawn_mower_active() and !trigger_upon_lawn_completion:
			spawn()
			can_spawn = false
