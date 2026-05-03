extends Node2D

class_name WaveSpawner

"""
This is a script that will spawn waves of enemies once the player has finished
mowing every grass tile in the lawn.
"""

@export var spawn_interval: float = 3.0
# The list of points at which enemies can spawn
@export var spawn_points: Array[Node2D]
# A dictionay of enemy scenes that can be instantiated as enemies
# format: enemy id -> enemy scene
@export var enemy_scenes: Dictionary[String, PackedScene]
# An array representing the different waves of enemies that are spawned
# each string should be of the following format: enemy1_id,enemy2_id,enemy3_id,etc.
@export_multiline var waves: PackedStringArray
# Messages that should be sent as an alert when a new wave is spawned
# Empty strings do not get displayed
@export_multiline var alert_messages: PackedStringArray
# id of the spawn audio that should be played upon an enemy spawning
@export var spawn_audio: AudioStreamPlayer2D
@export var alert_audio: AudioStreamPlayer

var spawned_enemy_paths: Array[NodePath]
var spawn_timer: float = 0.0
var current_wave: int = 0
var enemies_to_spawn: PackedStringArray
var current_enemy: int = 0

@onready var lawn: Lawn = get_node_or_null("/root/Main/Lawn")
@onready var player: Player = $/root/Main/Player

func spawn_enemy() -> void:
	if current_enemy >= enemies_to_spawn.size():
		return
	if spawn_points.size() == 0:
		return
	var id: String = enemies_to_spawn[current_enemy]
	print('spawning: ', id)
	var enemy: Node2D = enemy_scenes[id].instantiate()
	if enemy is RobotEnemy:
		enemy.hostile = true
	# Pick a random position to spawn the enemy
	enemy.global_position = spawn_points[randi() % spawn_points.size()].global_position
	add_child(enemy)
	spawned_enemy_paths.push_back(enemy.get_path())
	if spawn_audio:
		var audio: AudioStreamPlayer2D = spawn_audio.duplicate()
		audio.global_position = enemy.global_position
		lawn.add_child(audio)
		audio.play()

func start_new_wave() -> void:
	if current_wave >= waves.size():
		return
	spawned_enemy_paths.clear()
	enemies_to_spawn = waves[current_wave].split(",")
	print(enemies_to_spawn)
	current_enemy = 0
	spawn_enemy()
	current_enemy += 1
	spawn_timer = spawn_interval
	var message: String = ""
	if current_wave < alert_messages.size():
		message = alert_messages[current_wave]
	var alert_args: PackedStringArray = message.split("\n")
	if alert_args.size() >= 3:
		$/root/Main/HUD.alert(alert_args[0], alert_args[1], alert_args[2], true)
		if alert_audio:
			alert_audio.play()
	current_wave += 1

func can_start_new_wave() -> bool:
	for node_path: NodePath in spawned_enemy_paths:
		if get_node_or_null(node_path):
			return false
	return true

func _process(delta: float) -> void:
	if lawn == null:
		return

	if player.health <= 0:
		return

	if lawn.cut_grass_tiles < lawn.total_grass_tiles:
		return

	spawn_timer -= delta
	if spawn_timer <= 0.0:
		spawn_enemy()
		current_enemy += 1
		spawn_timer = spawn_interval

	if current_wave >= waves.size():
		return

	if can_start_new_wave() and current_enemy >= enemies_to_spawn.size():
		start_new_wave()
