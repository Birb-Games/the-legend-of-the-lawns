extends Nest

@export var wasp_queen_scene: PackedScene

func explode() -> void:
	super.explode()

	var parent: Node2D = get_node_or_null("/root/Main/Lawn/MobileEnemies")
	if parent:
		# Spawn in wasp queen when nest is destroyed
		var wasp_queen: MobileEnemy = wasp_queen_scene.instantiate()
		wasp_queen.global_position = global_position
		parent.add_child(wasp_queen)
