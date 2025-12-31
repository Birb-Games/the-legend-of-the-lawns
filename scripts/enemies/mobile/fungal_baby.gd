extends MobileEnemy

@onready var default_speed: float = speed
const POWER: float = 2.0
const EXPLOSION_TIME: float = 2.0
var explosion_timer: float = 0.0
@export var explosion_flash_gradient: Gradient
var start_explosion_timer: bool = false
# How long we pause for f we are hit
const STOP_TIME: float = 0.5
const IMMUNITY_TIME: float = 0.75
var hit_timer: float = 0.0

func _ready() -> void:
	super._ready()
	$AnimatedSprite2D.animation = "spawn"

func get_animation() -> String:
	if spawn_timer > 0.1:
		return "spawn"
	if velocity.length() == 0.0:
		return "idle"
	return "running"

func in_shooting_range() -> bool:
	var player_dist: float = (player.global_position - global_position).length()
	return player_dist < 160.0 and player_dist > 50.0

func shoot() -> void:
	if randi() % 3 == 0:
		return
	super.shoot()

func set_dir_left() -> void:
	$AnimatedSprite2D.flip_h = true

func set_dir_right() -> void:
	$AnimatedSprite2D.flip_h = false

func set_sprite_dir() -> void:
	if player.global_position.x < global_position.x - 8.0:
		set_dir_left()
	elif player.global_position.x > global_position.x + 8.0:
		set_dir_right()

	var vel = calculate_velocity()
	if vel.length() > 0.0 and vel.normalized().dot(Vector2.LEFT) > 0.25:
		set_dir_left()
	elif vel.length() > 0.0 and vel.normalized().dot(Vector2.RIGHT) > 0.25:
		set_dir_right()

func calculate_velocity() -> Vector2:
	if hit_timer > IMMUNITY_TIME:
		return Vector2.ZERO

	var vel = super.calculate_velocity()
	if (player.global_position - global_position).length() < 24.0:
		return vel * 0.5
	else:
		return vel

func _process(delta: float) -> void:
	$Shadow.visible = spawn_timer <= 0.0
	$SpawnShadow.visible = !$Shadow.visible

	if explosion_timer >= EXPLOSION_TIME:
		explosion_bullet_count *= 4
		explode()
		# Apply damage to the player based on how far away the player is
		var dist = (player.global_position - global_position).length() / 16.0
		var player_damage = max(int(floor(40.0 - dist * dist * 10.0)), 0)
		player.damage(player_damage)
		return

	super._process(delta)
	set_sprite_dir()

	if hit_timer > 0.0:
		hit_timer -= delta
	
	# If we get close enough to the player, begin the detonation process
	if (player.global_position - global_position).length() < 32.0:
		start_explosion_timer = true
	
	if start_explosion_timer:
		explosion_timer += delta
		var sine = sin(8.0 * pow(pow(3.0 * PI / 2.0, 1.0 / POWER) + explosion_timer, POWER))
		var sample_point = (sine + 1.0) / 2.0
		$AnimatedSprite2D.modulate = explosion_flash_gradient.sample(sample_point)

func _on_hit() -> void:
	if hit_timer > 0.0:
		return

	if start_explosion_timer:
		hit_timer = STOP_TIME * 0.5 + IMMUNITY_TIME
	else:
		hit_timer = STOP_TIME + IMMUNITY_TIME

