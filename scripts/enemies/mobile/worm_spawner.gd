extends Node2D

@export var worm_scene: PackedScene
var can_spawn: bool = true

func spawn() -> void:
	if !can_spawn:
		return

	var lawn: Node2D = get_node_or_null("/root/Main/Lawn")
	if lawn == null:
		return

	var enemy: Node2D = worm_scene.instantiate()
	enemy.global_position = global_position
	lawn.call_deferred("add_child", enemy)

func _on_activation_zone_body_entered(body: Node2D) -> void:
	if body is Player:
		if body.lawn_mower_active():
			spawn()
			can_spawn = false
