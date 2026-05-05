extends SecurityGuard

@export var explosion_scene: PackedScene
@export var fire_scene: PackedScene
@export var orbital_strike_scene: PackedScene
var orbital_strike_timer: float = 5.0
var second_phase: bool = false

const SECOND_PHASE_TEXT: String = "That's it, I've had it with this kid! Hit'em with the orbital laser!"

func shoot() -> void:
	$Shoot.play()
	shoot_bullet(-PI / 5.0)
	shoot_bullet()
	shoot_bullet(PI / 5.0)

func explode() -> void:
	var explosion: Explosion = explosion_scene.instantiate()
	explosion.global_position = $AnimatedSprite2D.global_position
	explosion.scale *= 0.55
	explosion.can_damage_mobile = true
	explosion.can_damage_plants = true
	explosion.damage = 60
	Sfx.play_at_pos(explosion.global_position, "explosion", lawn)
	lawn.add_child(explosion)

	# Add fire
	var fire: Fire = fire_scene.instantiate()
	fire.global_position = global_position
	fire.lifetime += 2.0
	lawn.add_child(fire)
	var count: int = randi_range(8, 10)
	for i in range(count):
		var dist: float = randf_range(1.0, 3.0)
		var angle: float = randf_range(0.0, 2.0 * PI)
		var dir: Vector2 = Vector2(cos(angle), sin(angle))
		var fire_position: Vector2 = global_position + dist * dir * lawn.tile_size
		var tile_x: int = int(floor(fire_position.x / lawn.tile_size.x))
		var tile_y: int = int(floor(fire_position.y / lawn.tile_size.y))
		if !(Vector2i(tile_x, tile_y) in lawn.valid_spawn_tiles):
			continue
		fire = fire_scene.instantiate()
		fire.global_position = fire_position
		lawn.add_child(fire)

func _process(delta: float) -> void:
	if health <= 0:
		explode()
		lawn.bosses_killed += 1
		queue_free()
		return
	super._process(delta)

	if health <= int(max_health / 2.0) and !second_phase:
		second_phase = true
		$/root/Main/HUD.alert("Alien Mob Boss", SECOND_PHASE_TEXT, "Oh crud.", true)

	if player.health > 0 and second_phase:
		orbital_strike_timer -= delta
	if orbital_strike_timer < 0.0:
		$Shoot.play()
		pause_timer = 1.0
		orbital_strike_timer = randf_range(7.0, 10.0)
		var orbital_strike = orbital_strike_scene.instantiate()
		orbital_strike.global_position = player.global_position + player.velocity * 2.0
		lawn.add_child(orbital_strike)
