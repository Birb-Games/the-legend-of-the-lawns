# This script should be applied to the "Pull" child of the player object

extends Area2D

var mower_in_range: bool

func _ready() -> void:
	mower_in_range = false

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("lawnmower"):
		mower_in_range = true

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("lawnmower"):
		mower_in_range = false
