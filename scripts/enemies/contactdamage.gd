# Reuse this script for other enemies that should have contact damage with the player
extends Area2D

@onready var player: Player = $/root/Main/Player
@export var damage_amt: int = 1
var can_attack_player: bool = false
# In seconds
@export var attack_cooldown: float = 1.75
var attack_timer: float = 0.0

func _process(delta: float) -> void:
	attack_timer -= delta
	# Attempt to bite player
	if can_attack_player and attack_timer <= 0.0:
		player.damage(damage_amt)
		attack_timer = attack_cooldown

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		can_attack_player = true

func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		can_attack_player = false
