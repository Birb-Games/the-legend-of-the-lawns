class_name PlayerBullet

extends Area2D

const ROTATION_SPEED: float = 180.0
const SPEED: float = 140.0

var dir: Vector2 = Vector2.ZERO
var lifetime: float = 5.0
var can_hit_player: bool = false
var can_activate_sprinkler: bool = true

@export var damage: int = 1

func active() -> bool:
	return $Sprite2D.visible

func explode() -> void:
	$Explosion.emitting = true
	$Sprite2D.hide()
	$GPUParticles2D.emitting = false
	$Splash.play()

func _process(delta: float) -> void:
	if lifetime > 0.0:
		lifetime -= delta
		if lifetime <= 0.0:
			explode()
	
	if $Sprite2D.visible:
		position += SPEED * dir * delta
		rotation += ROTATION_SPEED * delta
	
	# Bullet is dead if not emitting particles and not visible
	if !$Explosion.emitting and !$Sprite2D.visible and !$Splash.playing:
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("lawn_obstacle"):
		explode()
	elif body is Player:
		if can_hit_player:
			body.damage(1)
			body.fire_timer = 0.0
			explode()
