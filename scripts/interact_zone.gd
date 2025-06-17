# This script should be applied to the "Pull" child of the player object

extends Area2D

var can_pull: bool

func _ready() -> void:
	can_pull = false

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("lawnmower"):
		can_pull = true

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("lawnmower"):
		can_pull = false
