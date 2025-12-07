class_name GameCamera

extends Camera2D

# Shake code implemented from this tutorial:
# https://kidscancode.org/godot_recipes/4.x/2d/screen_shake/index.html 

const DECAY: float = 0.6
const MAX_OFFSET: Vector2 = Vector2(12, 12)
const MAX_ROLL: float = 0.8
const TRAUMA_POWER: int = 2
var trauma: float = 0.0

@onready var noise: FastNoiseLite = FastNoiseLite.new()
var noise_y: float = 0.0

func add_trauma(amt: float) -> void:
	trauma += amt
	trauma = min(trauma, 1.0)

func shake() -> void:
	var amount = pow(trauma, TRAUMA_POWER)
	rotation = MAX_ROLL * amount * noise.get_noise_2d(noise.seed, noise_y)
	offset.x = MAX_OFFSET.x * amount * noise.get_noise_2d(noise.seed * 2, noise_y)
	offset.y = MAX_OFFSET.y * amount * noise.get_noise_2d(noise.seed * 3, noise_y)

func _process(delta: float) -> void:
	if trauma > 0.0:
		trauma = max(trauma - DECAY * delta, 0.0)
		shake()
		noise_y += 1000.0 * delta
