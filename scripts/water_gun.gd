extends Sprite2D

@onready var particles: GPUParticles2D = $GPUParticles2D
@onready var raycast: RayCast2D = $RayCast2D

var radius = position.x

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("shoot"):
		particles.emitting = true
		raycast.enabled = true
	if Input.is_action_pressed("shoot"):
		position = (get_global_mouse_position() - get_parent().position).normalized() * radius
		rotation = (get_global_mouse_position() - get_parent().position).normalized().angle()
		if raycast.is_colliding():
			print("Water gun is hitting: ", raycast.get_collider().name)
	else:
		get_child(0).emitting = false
		raycast.enabled = false
