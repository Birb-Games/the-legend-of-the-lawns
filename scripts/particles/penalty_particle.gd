extends GPUParticles2D

class_name PenaltyParticle

# As a workaround to an issue that we found in which the particle seems to cause
# a lag spike when first instantiated.
# The fix was to instantiate the particle for one time in the main scene at the
# beginning of the game to avoid lag spikes afterwards - this particle is marked
# with the `first_instance` flag (all other particles should have this flag set
# to false) - if this flag is set to true, the particle's text is set to an
# empty string so that it is not visible and then activated so that whatever
# Godot needs to do in order to eliminate the lag spike is done at the start
# of the game, not during a less desirable time, such as during gameplay.
@export var first_instance: bool = false

var has_emitted: bool = false
static var particle_scene: PackedScene = preload("uid://bqis403nmimnk")

# Constructs a penalty particle at the given position with the specified amount.
# Requires parent because get_node does not work in static functions.
static func emit_penalty(penalty: int, placement_position: Vector2, parent: Node) -> void:
	var penalty_particle: PenaltyParticle = particle_scene.instantiate()
	penalty_particle.position = placement_position
	penalty_particle.activate(penalty)
	parent.add_child(penalty_particle)

func activate(penalty: int) -> void:
	$SubViewport/Label.text = "-$%d" % penalty
	emitting = true

func _ready() -> void:
	# if this is the first instance of the particle, set the text to be a
	# blank string and activate the particle effect
	if first_instance:
		emitting = true
		$SubViewport/Label.text = ""

func _process(_delta: float) -> void:
	if emitting:
		has_emitted = true
	elif has_emitted:
		# Particle is done emitting, delete it
		queue_free()
