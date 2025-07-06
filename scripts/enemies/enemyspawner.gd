extends Node2D

@export var enemies: Array[PackedScene]
@export var difficulty: int = 0
# Set this to 0 if you want a random number of enemies
# This should probably be a value <= 7
@export var spawn_count: int = 0
var can_spawn: bool = true
# Set this to a value > 0.0 if you want enemies to potentially pre-generate
# Set it to 1 if you want enemies to spawn immediately
# Note that if the value is greater than 0.0, then it will not spawn enemies
# when the lawn mower gets within the "Activation Zone"
@export var spawn_probability: float = 0.0

# Spawns only one type of enemy
func spawn_single_type(count: int) -> void:
	var weights = Spawning.get_weights(Spawning.WEED_WEIGHT_TABLE, difficulty)
	var index = Spawning.get_rand_ind(weights)
	
	if count == 1:
		var enemy = enemies[index].instantiate()
		$Enemies.call_deferred("add_child", enemy)
		return
	
	var positions = Spawning.gen_enemy_positions_circle(count, 20.0, 4.0, 10.0)
	for i in range(count):
		var enemy = enemies[index].instantiate()
		enemy.position = positions[i]
		$Enemies.call_deferred("add_child", enemy)

# Spawns multiple types of enemies
func spawn_rand_types(count: int) -> void:
	var weights = Spawning.get_weights(Spawning.WEED_WEIGHT_TABLE, difficulty)
	var positions = Spawning.gen_enemy_positions_circle(count, 20.0, 4.0, 10.0)
	for i in range(count):
		var index = Spawning.get_rand_ind(weights)
		var enemy = enemies[index].instantiate()
		enemy.position = positions[i]
		$Enemies.call_deferred("add_child", enemy)

func spawn() -> void:
	if !can_spawn:
		return
	
	if $Enemies.get_child_count() > 0:
		return
	
	var enemy_count = spawn_count
	if enemy_count == 0:
		enemy_count = Spawning.gen_rand_count(Spawning.WEED_COUNT_TABLE, difficulty)
	
	if enemy_count == 1:
		spawn_single_type(1)
		return
	
	if randi() % 4 == 0:
		spawn_single_type(enemy_count)
	else:
		spawn_rand_types(enemy_count)

func _ready() -> void:
	difficulty += $/root/Main/HUD.get_current_neighbor().difficulty
	if randf() > spawn_probability:
		if spawn_probability > 0.0:
			can_spawn = false
		return	
	spawn()
	can_spawn = false

func _on_activation_zone_body_entered(body: Node2D) -> void:
	if body.is_in_group("lawnmower"):
		spawn()
		can_spawn = false
