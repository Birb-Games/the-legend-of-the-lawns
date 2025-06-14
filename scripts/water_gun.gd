extends Sprite2D

@onready var particles: GPUParticles2D = $GPUParticles2D
@onready var raycast: RayCast2D = $RayCast2D

var radius = position.x
var size = scale.x

func _ready() -> void:
	hide()

# For debug purposes,
# outputs the object that the water gun is hitting
func debug_output_target() -> void:
	if Input.is_action_pressed("shoot") and raycast.is_colliding():
		print("Water gun is hitting: ", raycast.get_collider().name)

func update_transform() -> void:
	position = (get_global_mouse_position() - get_parent().position).normalized() * radius
	rotation = (get_global_mouse_position() - get_parent().position).normalized().angle()
	if abs(rotation) < PI / 2:
		scale.y = size
	else:
		scale.y = -size

func _process(_delta: float) -> void:
	particles.emitting = visible
	raycast.enabled = visible
	
	if visible:
		update_transform()
		var shooting = Input.is_action_pressed("shoot")
		particles.emitting = shooting
		raycast.enabled = shooting
		debug_output_target()
