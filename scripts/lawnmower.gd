extends RigidBody2D

func _on_body_exited(body: Node) -> void:
	if body.is_in_group("player"):
		linear_velocity = Vector2.ZERO
