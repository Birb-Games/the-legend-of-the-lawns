extends Sprite2D

@onready var particles: GPUParticles2D = $GPUParticles2D
@onready var raycast: RayCast2D = $RayCast2D

@onready var radius = (position - get_parent().get_node("AnimatedSprite2D").position).length()
var size = scale.y

func _ready() -> void:
	hide()

# For debug purposes,
# outputs the object that the water gun is hitting
func debug_output_target() -> void:
	if Input.is_action_pressed("shoot") and raycast.is_colliding():
		print("Water gun is hitting: ", raycast.get_collider().name)

func update_transform() -> void:
	var player_pos = get_parent().get_node("AnimatedSprite2D").position
	var global_player_pos = get_parent().position + player_pos
	position = (get_global_mouse_position() - global_player_pos).normalized() * radius + player_pos
	rotation = (get_global_mouse_position() - global_player_pos).normalized().angle()
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
