extends MobileEnemy

@export var blood_particles_scene: PackedScene
@onready var default_contact_damage_pos: Vector2 = $ContactDamageZone.position
var idle_timer: float = 0.0
@onready var time_before_pause: float = gen_time_before_pause()
var stun_timer: float = 0.0
@onready var stun_particle_pos_x: float = $StunParticles.position.x
@onready var anger_particle_pos_x: float = $AngerParticles.position.x
@onready var damage_amt: int = $ContactDamageZone.damage_amt
var hit_timer: float = 0.0
var anger_timer: float = 0.0

func _ready() -> void:
	super._ready()
	$AnimatedSprite2D.animation = "spawn"

func gen_time_before_pause() -> float:
	return randf_range(3.0, 5.0)

func calculate_velocity() -> Vector2:
	var vel = super.calculate_velocity()
	if anger_timer > 0.0 and stun_timer <= 0.0:
		# Rabbit is extra fast when angry
		vel *= 1.33
		return vel
	if stun_timer > 0.0:
		return Vector2.ZERO
	if idle_timer > 0.0:
		return Vector2.ZERO	
	return vel

func get_animation() -> String:
	if spawn_timer > 0.1:
		return "spawn"
	if stun_timer > 0.0:
		return "stunned"
	if velocity.length() == 0.0:
		if $ContactDamageZone.can_attack_player():
			return "attack"
		return "idle"
	return "running"

func explode() -> void:
	var blood_particles: GPUParticles2D = blood_particles_scene.instantiate()
	blood_particles.global_position = global_position + Vector2(0.0, -10.0)
	$/root/Main/Lawn.add_child(blood_particles)
	queue_free()

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
	if spawn_timer > 0.0:
		spawn_timer -= delta
		return

	stun_timer -= delta
	stun_timer = max(stun_timer, 0.0)
	# Show stun particles
	$StunParticles.emitting = stun_timer > 0.1
	$StunParticles.visible = stun_timer > 0.01
	# Show anger particles
	$AngerParticles.emitting = anger_timer > 0.1 and stun_timer <= 0.0
	$AngerParticles.visible = anger_timer > 0.01 and stun_timer <= 0.0

	hit_timer -= delta
	hit_timer = max(hit_timer, 0.0)

	# Set damage
	if stun_timer > 0.0:
		$ContactDamageZone.damage_amt = 0
	elif anger_timer > 0.0:
		$ContactDamageZone.damage_amt = damage_amt * 2
	else:
		$ContactDamageZone.damage_amt = damage_amt

	super._process(delta)

	if stun_timer > 0.0:
		return

	anger_timer -= delta
	anger_timer = max(anger_timer, 0.0)

	# Set direction of rabbit
	if velocity.dot(Vector2.LEFT) > 0.1:
		$AnimatedSprite2D.flip_h = true
		$StunParticles.position.x = -stun_particle_pos_x
		$AngerParticles.position.x = -anger_particle_pos_x
	elif velocity.dot(Vector2.RIGHT) > 0.1:
		$AnimatedSprite2D.flip_h = false
		$StunParticles.position.x = stun_particle_pos_x
		$AngerParticles.position.x = anger_particle_pos_x

	if idle_timer <= 0.0 and anger_timer <= 0.0:
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

func damage(amt: int) -> void:
	# If the rabbit is stunned, do not take damage
	if stun_timer > 0.0:
		return
	# Rabbit gains some resistance to damage when angry
	if anger_timer > 0.0 and randi() % 2 == 0 and amt <= 2:
		return
	super.damage(amt)

func _on_hit() -> void:
	# If the rabbit was hit with two consecutive shots, stun it
	if hit_timer > 0.0 and anger_timer <= 0.0:
		stun_timer = 7.0 + randf_range(0.0, 3.0)
		anger_timer = 7.0
		time_before_pause = gen_time_before_pause()
		$StunParticles.restart()
		$AngerParticles.restart()
	if stun_timer <= 0.01:
		hit_timer = 0.4
