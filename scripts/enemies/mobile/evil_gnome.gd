extends MobileEnemy

var active: bool = false
var current_vel: Vector2 = Vector2.ZERO
const CHANGE_DIR_INTERVAL: float = 0.1
var change_dir_timer: float = 0.0
var change_vel_timer: float = 0.0
var can_bounce: bool = true
var lifetime: float = 30.0

func _ready() -> void:
	super._ready()

func calculate_velocity() -> Vector2:
	if !active:
		return Vector2.ZERO
	return current_vel * speed

func shoot() -> void:
	if !active:
		return

	var count: int = randi_range(4, 7)
	for i in range(count):
		shoot_bullet(2.0 * PI / float(count) * float(i))

func get_animation() -> String:
	if !active:
		return "inactive"
	if velocity.length() <= 0.0:
		return "idle"
	return "running"

func set_sprite_dir() -> void:
	if calculate_velocity().x < 0.0:
		set_dir_left()
	else:
		set_dir_right()

func _process(delta: float) -> void:	
	super._process(delta)
	$ContactDamageZone.disabled = !active

	if !active:
		return

	change_dir_timer -= delta
	if change_dir_timer < 0.0:
		set_sprite_dir()
		change_dir_timer = CHANGE_DIR_INTERVAL
	
	change_vel_timer -= delta
	if change_vel_timer <= 0.0:
		change_velocity()
	
	lifetime -= delta
	if lifetime <= 0.0:
		explode()	

func change_velocity() -> void:
	var angle: float = randf_range(0.0, 2.0 * PI)
	current_vel = Vector2(cos(angle), sin(angle))
	change_vel_timer = randf_range(1.0, 4.0)

func activate() -> void:
	active = true
	change_velocity()
	$ContactDamageZone.disabled = false

func damage(amt: int) -> void:
	if !active:
		activate()
		return
	super.damage(amt)

func _physics_process(delta: float) -> void:
	var prev_pos: Vector2 = global_position
	super._physics_process(delta)
	var diff = global_position - prev_pos
	if diff.length() <= speed * 0.6 * delta and !can_bounce:
		reverse_direction()

func _on_bullet_hitbox_body_entered(body: Node2D) -> void:
	if body is Player:
		if body.lawn_mower_active() and !active:
			activate()

func reverse_direction() -> void:
	var prev_vel: Vector2 = current_vel
	for i in range(10):
		change_velocity()
		change_vel_timer = 0.25
		if current_vel.dot(prev_vel) < -0.2:
			return
	current_vel = -prev_vel

func _on_wall_detector_body_entered(body: Node2D) -> void:	
	if body is TileMapLayer:
		if can_bounce:
			reverse_direction()
		can_bounce = false

func _on_wall_detector_body_exited(body: Node2D) -> void:
	if body is TileMapLayer:
		can_bounce = true

