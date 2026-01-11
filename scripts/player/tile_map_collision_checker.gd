"""
When the player changes their direction to move up while holding the lawn mower,
their hitbox actually expands a little to account for the lawn mower in front
so that we do not get a visual glitch of the lawn mower clipping into a fence.
However, this expansion of the hitbox can result in some bugs/the player clipping
into the fence so this script aims to avoid that by checking beforehand if the
hitbox is intersecting with anything. If not, we can safely change direction to
"up" without worrying about collision bugs, otherwise we do not bother changing
direction.
"""

extends Area2D

# Keeps track of the number of things this object is intersecting with,
# if this value is 0 then we are not colliding with anything
var intersection_count: int = 0

# Returns if we are colliding with anything
func colliding() -> bool:
	return intersection_count > 0

func _on_body_exited(body: Node2D) -> void:
	if body is TileMapLayer or body is StaticBody2D:
		intersection_count -= 1

func _on_body_entered(body: Node2D) -> void:
	if body is TileMapLayer or body is StaticBody2D:
		intersection_count += 1

