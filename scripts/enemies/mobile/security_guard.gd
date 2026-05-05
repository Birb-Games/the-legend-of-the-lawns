extends MobileEnemy

var pause_timer: float = 0.0
@onready var default_shadow_scale: Vector2 = $Shadow.scale
@onready var gun_radius: float = $Gun.position.x
@onready var gun_size: float = $Gun.scale.y
var fade_away_timer: float = 3.0
@onready var pause_interval_timer: float = randf_range(4.0, 10.0)

func update_gun_transform() -> void:
	var center = $AnimatedSprite2D.position
	$Gun.position = (player.global_position - $AnimatedSprite2D.global_position).normalized() * gun_radius + center
	$Gun.rotation = (player.global_position - $AnimatedSprite2D.global_position).normalized().angle()
	if abs($Gun.rotation) < PI / 2:
		$Gun.scale.y = gun_size
	else:
		$Gun.scale.y = -gun_size
	$BulletSpawnPoint.global_position = $Gun/BulletSpawnPoint.global_position

func _ready() -> void:
	if spawn_timer > 0.0:
		modulate.a = 0.0
	var spawn_particle: GPUParticles2D = get_node_or_null("SpawnParticles")
	if spawn_particle:
		spawn_particle.emitting = true
	speed *= randf_range(1.0, 1.125)
	lawn.boss_count += 1
	$AnimatedSprite2D/StunParticles.hide()
	$AnimatedSprite2D/StunParticles.emitting = false
	super._ready()

func calculate_velocity() -> Vector2:
	if health <= 0 or pause_timer > 0.0:
		return Vector2.ZERO
	return super.calculate_velocity()

func get_animation() -> String:
	if health <= 0:
		return "knocked_out"

	if velocity.length() == 0.0:
		return "idle"

	if velocity.normalized().dot(Vector2.DOWN) > 0.9:
		return "walking"

	return "walking_side"

func explode() -> void:
	pass

func shoot() -> void:
	$Shoot.play()
	super.shoot()

func _process(delta: float) -> void:
	pause_timer = max(pause_timer - delta, 0.0)
	if (player.global_position - global_position).length() <= min_chase_distance:
		pause_timer = 0.75
	if pause_timer <= 0.0:
		pause_interval_timer -= delta
	if pause_interval_timer <= 0.0:
		pause_timer = randf_range(1.0, 4.0)
		pause_interval_timer = randf_range(4.0, 10.0)
	if health <= 0:
		$Gun.hide()
		$AnimatedSprite2D.flip_h = true
		$AnimatedSprite2D.flip_v = false
		$AnimatedSprite2D/StunParticles.show()
		$AnimatedSprite2D/StunParticles.emitting = true
		$AnimatedSprite2D.animation = "knocked_out"
		$AnimatedSprite2D.rotation = deg_to_rad(90.0)
		$AnimatedSprite2D.position = Vector2(0.0, -7.5)
		$Shadow.scale = Vector2(default_shadow_scale.x * 3.0, default_shadow_scale.y * 2.8)
		$Shadow.position = Vector2(0.0, -5.0)
		$Healthbar.hide()
		$ContactDamageZone.disabled = true
		if fade_away_timer <= 0.0:
			modulate.a -= delta * 0.25
		else:
			fade_away_timer -= delta
		if modulate.a <= 0.0:
			lawn.bosses_killed += 1
			queue_free()
		return
	if spawn_timer > 0.0:
		modulate.a = (cos(5.0 * PI * spawn_timer) + 1.0) / 2.0
	else:
		modulate.a = 1.0
	set_sprite_dir()
	update_gun_transform()
	super._process(delta)

func _on_bullet_hitbox_area_entered(body: Node2D) -> void:
	if body.get_parent() is Explosion:
		return
	if body is ElectricShock:
		if body.can_damage_player:
			return
	super._on_bullet_hitbox_area_entered(body)

func damage(amt: int) -> void:
	if spawn_timer > 0.0:
		return
	var prev_health: int = health
	super.damage(amt)
	if health <= 0 and prev_health > 0:
		$Hit.volume_db = 18.0
		$Hit.play()
	elif health > 0 and !$Hit.playing:
		$Hit.play()

func _on_hit() -> void:
	pass
