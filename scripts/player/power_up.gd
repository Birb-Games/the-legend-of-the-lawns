extends Area2D

class_name PowerUp

static var power_up_scene: PackedScene = preload("uid://o1e8sispk3lw")
const POWER_UP_LIST: Array[String] = [
	"tomato",
	"spaghetti",
	"eggplant",
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
			player.heal(50)
		"spaghetti":
			var prev_time: float = player.get_status_effect_time("speed")
			player.set_status_effect_time("speed", prev_time + 30.0)
		"eggplant":
			var prev_time: float = player.get_status_effect_time("eggplant")	
			player.set_status_effect_time("eggplant", prev_time + 15.0)
			player.eggplant_timer = 0.0
	return true

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		if apply_power_up(body):
			$/root/Main.play_sfx("Eat")
			queue_free()

static func spawn(parent: Node, pos: Vector2, power_up_type: String = "") -> void:
	var power_up_instance: PowerUp = power_up_scene.instantiate()
	power_up_instance.position = pos
	if power_up_type.is_empty():
		power_up_instance.power_up = POWER_UP_LIST[randi() % len(POWER_UP_LIST)]
	else:
		power_up_instance.power_up = power_up_type
	parent.add_child(power_up_instance)
