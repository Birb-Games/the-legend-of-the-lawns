class_name EnemyBullet

extends Area2D

@export var speed: float = 0.0
# Degrees per second
@export var rotation_speed: float = 0.0
@export var damage_amt: int = 1
# in seconds
@export var lifetime: float = 1.0
# Whether the bullet points in the direction it is going or if it
# just rotates as it moves
@export var directional: bool = false
var timer: float = 0.0

# Should have magnitude 1.0
var dir: Vector2 = Vector2.ZERO

func _ready() -> void:
	timer = lifetime

func explode() -> void:
	var trail: GPUParticles2D = get_node_or_null("BulletTrail")
	if trail:
		trail.hide()
	$Sprite2D.hide()
	$GPUParticles2D.emitting = true

func active() -> bool:
	return $Sprite2D.visible

func _process(delta: float) -> void:
	timer -= delta
	if timer < 0.0:
		explode()
		return
	
	if $Sprite2D.visible:
		position += dir * speed * delta
		if !directional:
			rotation += rotation_speed * PI / 180.0 * delta
		else:
			rotation = dir.angle()
	
	# Sprite hidden and particles no longer emitting = dead
	if !$Sprite2D.visible and !$GPUParticles2D.emitting:
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("lawn_obstacle") and $Sprite2D.visible:
		explode()

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_hitbox") and $Sprite2D.visible:
		explode()
		$/root/Main/Player.damage(damage_amt)
