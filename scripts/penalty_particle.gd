extends GPUParticles2D

class_name PenaltyParticle

var has_emitted: bool = false
static var particle_scene: PackedScene = preload("res://scenes/penalty_particle.tscn")

# Constructs a penalty particle at the given position with the specified amount.
# Requires parent because get_node does not work in static functions.
static func emit_penalty(penalty: int, placement_position: Vector2, parent: Node) -> void:
	var penalty_particle: PenaltyParticle = particle_scene.instantiate()
	penalty_particle.position = placement_position
	penalty_particle.get_child(0).get_child(0).text = "-$%d" % penalty
	penalty_particle.emitting = true
	parent.add_child(penalty_particle)

func _process(_delta: float) -> void:
	if emitting:
		has_emitted = true
	elif has_emitted:
		queue_free()
		return
