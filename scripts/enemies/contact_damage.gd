# Reuse this script for other enemies that should have contact damage with the player
extends Area2D

@onready var player: Player = $/root/Main/Player
@export var damage_amt: int = 1
# In seconds
@export var attack_cooldown: float = 1.75
var attack_timer: float = 0.0

func can_attack_player() -> bool:
	var player_pos: Vector2 = player.global_position
	if player.lawn_mower_active():
		player_pos += player.get_lawn_mower_dir_offset()
	return global_position.distance_to(player_pos) < $CollisionShape2D.shape.radius

func _process(delta: float) -> void:
	# Ignore if the lawn is not loaded
	if !$/root/Main.lawn_loaded:
		return

	attack_timer -= delta
	# Attempt to bite player
	if can_attack_player() and attack_timer <= 0.0:
		player.damage(damage_amt)
		attack_timer = attack_cooldown
