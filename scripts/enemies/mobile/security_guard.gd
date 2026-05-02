extends MobileEnemy

var pause_timer: float = 0.0

func _ready() -> void:
	lawn.boss_count += 1
	super._ready()

func get_animation() -> String:
	if velocity.length() == 0.0:
		return "idle"

	if velocity.normalized().dot(Vector2.DOWN) > 0.9:
		return "walking"

	return "walking_side"

func explode() -> void:
	lawn.bosses_killed += 1
	queue_free()

func _process(delta: float) -> void:
	pause_timer = max(pause_timer - delta, 0.0)
	if (player.global_position - global_position).length() <= min_chase_distance:
		pause_timer = 0.75
	super._process(delta)
	set_sprite_dir()

func _on_bullet_hitbox_area_entered(body: Node2D) -> void:
	if body.get_parent() is Explosion:
		return
	super._on_bullet_hitbox_area_entered(body)
