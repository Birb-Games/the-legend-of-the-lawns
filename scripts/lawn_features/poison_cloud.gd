extends Area2D

class_name Poison

const LIFETIME: float = 7.0
var time: float = 0.0

func _process(delta: float) -> void:
	time += delta

	# Poison cloud's lifetime is the lowest
	if time > LIFETIME:
		$GPUParticles2D.emitting = false
	
	if time > LIFETIME + $GPUParticles2D.lifetime:
		queue_free()
