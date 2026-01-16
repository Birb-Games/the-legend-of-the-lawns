extends GPUParticles2D

class_name OneShotParticles

func _ready() -> void:
	emitting = true

func _process(_delta: float) -> void:
	if !emitting:
		queue_free()
