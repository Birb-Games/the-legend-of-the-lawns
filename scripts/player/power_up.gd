extends Area2D

const POWER_UP_LIST: Array[String] = [
	"tomato",
]
@export var power_up: String = "tomato"
@onready var sprite_y: float = $AnimatedSprite2D.position.y
var time: float = 0.0

func _ready() -> void:
	$AnimatedSprite2D.animation = power_up

func _process(delta: float) -> void:
	time += delta
	$AnimatedSprite2D.position.y = sprite_y + sin(time * 2.0) * 2.0

func apply_power_up(player: Player) -> bool:
	if player.health <= 0:
		return false

	match power_up:
		"tomato":
			if player.health == player.get_max_health():
				return false
			player.heal(20)
	return true

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		if apply_power_up(body):
			$/root/Main.play_sfx("Eat")
			queue_free()
