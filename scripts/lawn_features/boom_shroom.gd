extends Area2D

class_name BoomShroom

var explode_flag: bool = false
var explosion_timer: float = 0.0
@export var explosion_scene: PackedScene
@export var fire_scene: PackedScene
@export var explosion_flash_gradient: Gradient
const POWER: float = 2.0

func _process(delta: float) -> void:
	if !explode_flag:
		return
	explosion_timer += delta
	var sine = sin(6.0 * pow(pow(3.0 * PI / 2.0, 1.0 / POWER) + explosion_timer, POWER))
	var sample_point = (sine + 1.0) / 2.0
	$Sprite2D.modulate = explosion_flash_gradient.sample(sample_point)
	if explosion_timer >= 1.0:
		var camera: GameCamera = $/root/Main/Player/Camera2D
		camera.add_trauma(0.5)
		# Create explosion
		var explosion: Explosion = explosion_scene.instantiate()
		explosion.damage = 30
		explosion.global_position = $Sprite2D.global_position
		explosion.modulate = Color.CYAN
		explosion.can_damage_mobile = true
		explosion.can_damage_plants = true
		explosion.scale *= 0.3
		$/root/Main/Lawn.add_child(explosion)
		# Play explosion sound
		Sfx.play_at_pos(global_position, "explosion", get_node_or_null("/root/Main/Lawn"), 0.2)
		# Add a small fire
		var fire: Fire = fire_scene.instantiate()
		fire.lifetime = 0.6
		fire.global_position = global_position
		$/root/Main/Lawn.add_child(fire)
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		explode_flag = true

func _on_area_entered(area: Area2D) -> void:
	if area.get_parent() is Explosion:
		explode_flag = true
