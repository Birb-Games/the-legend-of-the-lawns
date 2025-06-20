extends Area2D

@onready var player: Player = $/root/Main/Player
const BITE_DAMAGE: int = 2
var can_bite_player: bool = false
var ATTACK_COOLDOWN: float = 1.75
var attack_timer: float = 0.0

func _process(delta: float) -> void:
	attack_timer -= delta
	# Attempt to bite player
	if can_bite_player and attack_timer <= 0.0:
		player.damage(BITE_DAMAGE)
		attack_timer = ATTACK_COOLDOWN

func _on_bite_radius_body_entered(body: Node2D) -> void:
	if body is Player:
		can_bite_player = true

func _on_bite_radius_body_exited(body: Node2D) -> void:
	if body is Player:
		can_bite_player = false
