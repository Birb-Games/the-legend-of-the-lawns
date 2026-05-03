extends MobileEnemy

class_name RobotEnemy

const ANGER_TEXT: String = """ERROR ERROR HOSTILE DETECTED - ENGAGING... 
ACTIVIATING SELF DEFENSE SUBROUTINES DESTROY THREAT DESTROY THREAT DESTROY THREAT"""

const SECOND_PHASE_TEXT: String = """WARNING: SYSTEMS SEVERELY DAMAGED
UPGRADING THREAT LEVEL - ACTIVATING LETHAL RESPONSE SUBROUTINES
DESTROY THREAT DESTROY THREAT DESTROY THREAT"""

@export var explosion_scene: PackedScene
@export var fire_scene: PackedScene
@export var electric_shock_scene: PackedScene
var hostile: bool = false
var pause_timer: float = 0.0
var basic_attack_timer: float = 0.0
const BASIC_ATTACK_TIMER_COOLDOWN: float = 1.0
# List of positions to spawn shock attacks
var attack_queue: Array[Vector2] = []
var pop_attack_queue_timer: float = 0.0
const POP_ATTACK_QUEUE_COOLDOWN: float = 0.2
var big_attack_timer: float = 2.0
const BIG_ATTACK_TIMER_COOLDOWN: float = 6.0
const ATTACKS: Array[String] = [ "line", "circle", "random" ]
var second_phase: bool = false

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
	
	var explosion: Explosion = explosion_scene.instantiate()
	explosion.scale *= 0.5
	explosion.can_damage_plants = true
	explosion.can_damage_mobile = true
	explosion.damage = 120
	explosion.global_position = $AnimatedSprite2D.global_position
	lawn.add_child(explosion)

	# Play explosion
	Sfx.play_at_pos(global_position, "explosion", lawn)

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
	
	queue_free()

func calculate_velocity() -> Vector2:
	if !hostile or pause_timer > 0.0 or attack_queue.size() > 0:
		return Vector2.ZERO

	return super.calculate_velocity()

func basic_shock_attack() -> void:
	var electric_shock: ElectricShock = electric_shock_scene.instantiate()
	electric_shock.can_damage_player = true
	electric_shock.position = $AnimatedSprite2D.position
	call_deferred("add_child", electric_shock)

func big_attack() -> void:
	var attack_type = ATTACKS[randi() % ATTACKS.size()]
	match attack_type:
		"line":
			var player_dist: float = (player.global_position - global_position).length()
			var dist: float = 0.0
			var dir: Vector2 = (player.global_position - global_position).normalized()
			while player_dist > 0.0:
				var pos: Vector2 = global_position + dist * dir
				attack_queue.push_back(pos)
				player_dist -= 16.0
				dist += 32.0
		"circle":
			var count: int = randi_range(6, 9)
			var player_angle: float = (player.global_position - global_position).angle()
			var angle_step: float = 2.0 * PI / float(count)
			for i in range(count):
				var angle: float = player_angle + angle_step * float(i) + PI
				var dir: Vector2 = Vector2(cos(angle), sin(angle))
				attack_queue.push_back(global_position + 80.0 * dir)
		"random":
			var count: int = randi_range(4, 6)
			for i in range(count):
				var dist: float = randf_range(0.0, 64.0)
				var angle: float = randf_range(0.0, 2.0 * PI)
				var dir: Vector2 = Vector2(cos(angle), sin(angle))
				attack_queue.push_back(global_position + dist * dir)
		_:
			pass

func attack(delta: float) -> void:
	if !hostile or player.health <= 0:
		return
	
	# Attempt to shock the player if they are too close
	if (player.global_position - global_position).length() < 64.0:
		basic_attack_timer -= delta
		if basic_attack_timer <= 0.0:
			basic_shock_attack()
			basic_attack_timer = BASIC_ATTACK_TIMER_COOLDOWN

	# Begin a large attack
	if attack_queue.size() <= 0:
		big_attack_timer -= delta
	if big_attack_timer < 0.0:
		big_attack_timer = randf_range(BIG_ATTACK_TIMER_COOLDOWN, BIG_ATTACK_TIMER_COOLDOWN + 2.0)
		big_attack()
	
	# Spawn attacks
	if !attack_queue.is_empty():
		pop_attack_queue_timer -= delta
		if pop_attack_queue_timer < 0.0:
			var pos: Vector2 = attack_queue[0]
			attack_queue.pop_front()
			var electric_shock: ElectricShock = electric_shock_scene.instantiate()
			electric_shock.can_damage_player = true
			electric_shock.global_position = pos
			lawn.add_child(electric_shock)
			$Zap.play()
			pop_attack_queue_timer = POP_ATTACK_QUEUE_COOLDOWN
		if attack_queue.is_empty():
			pause_timer = 0.5

func shoot() -> void:
	if !second_phase or pause_timer > 0.0:
		return
	shoot_bullet()

func _process(delta: float) -> void:
	pause_timer = max(pause_timer - delta, 0.0)
	if (player.global_position - global_position).length() <= min_chase_distance:
		pause_timer = 0.75
	super._process(delta)
	set_sprite_dir()
	$ContactDamageZone.disabled = !hostile
	attack(delta)

	if health < floori(max_health / 2.0) and !second_phase:
		second_phase = true
		$/root/Main/HUD.alert("Store Corp. Lawn Robot", SECOND_PHASE_TEXT, "Uh oh...", true)

func _on_hit() -> void:	
	if !hostile:
		hostile = true
		$/root/Main/HUD.alert("Store Corp. Lawn Robot", ANGER_TEXT, "RUN!", true)
		hostile = true
	
	$Hit.play()
	basic_shock_attack()

func _on_bullet_hitbox_area_entered(body: Node2D) -> void:
	if body.get_parent() is Explosion:
		return
	if body.is_in_group("shock"):
		return
	super._on_bullet_hitbox_area_entered(body)
