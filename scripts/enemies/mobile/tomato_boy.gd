extends MobileEnemy

@export var explosion_scene: PackedScene
var chase_player: bool = true
const CHANGE_DIR_INTERVAL: float = 0.1
var change_dir_timer: float = 0.0
var change_vel_timer: float = 0.0
var current_vel: Vector2 = Vector2.ZERO
var can_bounce: bool = true
var lifetime: float = 12.0
var resist_hit_timer: float = 0.0

func _ready() -> void:
	super._ready()
	$AnimatedSprite2D.animation = "spawn"

func calculate_velocity() -> Vector2:
	if lifetime <= 0.0:
		return Vector2.ZERO
	if spawn_timer > 0.0:
		return Vector2.ZERO
	if chase_player:
		return super.calculate_velocity()
	return current_vel

func get_animation() -> String:
	if lifetime <= 0.0:
		return "despawn"

	if spawn_timer > 0.0:
		return "spawn"

	if calculate_velocity().length() > 0.0:	
		return "running"
	else:
		return "idle"

func _on_hit() -> void:
	if resist_hit_timer > 0.0:
		return
	if !can_bounce:
		return
	var diff = global_position - player.global_position
	if diff.length() > 0.0:
		current_vel = diff.normalized() * speed * 1.8
	change_vel_timer = 3.0
	chase_player = false

func set_sprite_dir() -> void:
	super.set_sprite_dir()
	if chase_player:
		return
	if calculate_velocity().x > 0.0:
		set_dir_right()
	elif calculate_velocity().x < 0.0:
		set_dir_left()

func change_velocity() -> void:
	change_vel_timer = randf_range(1.0, 3.0)
	var angle = randf_range(0.0, 2.0 * PI)
	current_vel = Vector2(cos(angle), sin(angle)) * speed * 1.5

func _process(delta: float) -> void:
	$SpawnShadow.visible = spawn_timer > 0.0 or lifetime <= 0.0
	$Shadow.visible = !$SpawnShadow.visible

	super._process(delta)

	if lifetime < 0.0:
		$Healthbar.hide()
		return

	if spawn_timer > 0.0:
		return

	resist_hit_timer -= delta
	resist_hit_timer = max(resist_hit_timer, 0.0)

	if !chase_player:
		lifetime -= delta

	if !chase_player and get_animation() == "running":
		$AnimatedSprite2D.speed_scale = 1.5
	else:
		$AnimatedSprite2D.speed_scale = 1.0

	change_dir_timer -= delta
	if change_dir_timer < 0.0:
		set_sprite_dir()
		change_dir_timer = CHANGE_DIR_INTERVAL
	
	if !chase_player:
		change_vel_timer -= delta
	if change_vel_timer < 0.0:
		change_velocity()

func explode() -> void:
	var explosion: GPUParticles2D = explosion_scene.instantiate()
	explosion.position = position
	explosion.modulate = Color.RED
	explosion.scale *= 0.4
	$/root/Main/Lawn.add_child(explosion)
	queue_free()

func damage(amt: int) -> void:
	if lifetime <= 0.0:
		return
	super.damage(amt)

func _on_wall_detector_body_entered(body: Node2D) -> void:
	if body is TileMapLayer:
		if !chase_player and can_bounce:
			current_vel *= -1.0
			resist_hit_timer = 1.0
			can_bounce = false

func _on_wall_detector_body_exited(body: Node2D) -> void:
	if body is TileMapLayer:
		can_bounce = true

func _on_animated_sprite_2d_animation_finished() -> void:
	if $AnimatedSprite2D.animation == "despawn":
		queue_free()
