extends MobileEnemy

@onready var default_contact_damage_pos: Vector2 = $ContactDamageZone.position
var idle_timer: float = 0.0
@onready var time_before_pause: float = gen_time_before_pause()

func gen_time_before_pause() -> float:
	return randf_range(3.0, 5.0)

func calculate_velocity() -> Vector2:
	if idle_timer > 0.0:
		return Vector2.ZERO
	return super.calculate_velocity()

func handle_path_update(delta: float) -> bool:
	if idle_timer > 0.0:
		return false
	var updated: bool = super.handle_path_update(delta)
	var target: Vector2 = Vector2(
		(float(target_tile_pos.x) + 0.5) * lawn.tile_size.x,
		(float(target_tile_pos.y) + 0.5) * lawn.tile_size.y
	)
	if updated and (global_position - target).length() < lawn.tile_size.x * 1.25:
		idle_timer = randf_range(1.5, 3.0)
		time_before_pause = gen_time_before_pause()
	return updated

func _process(delta: float) -> void:
	super._process(delta)

	if idle_timer <= 0.0:
		time_before_pause -= delta
	
	if time_before_pause < 0.0 and idle_timer <= 0.0:
		idle_timer = randf_range(0.4, 0.8)
		time_before_pause = gen_time_before_pause()

	var diff = player.global_position - global_position
	if diff.length() > 0.0:
		diff = diff.normalized()
	$ContactDamageZone.position = default_contact_damage_pos + diff * 8.0

	if idle_timer > 0.0:
		idle_timer -= delta
		idle_timer = max(idle_timer, 0.0)
