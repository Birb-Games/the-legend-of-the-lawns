extends MobileEnemy

@export var explosion_scene: PackedScene
@export var fire_scene: PackedScene
@export var electric_shock_scene: PackedScene
@export var orbital_strike_scene: PackedScene

class Attack:
	var node: Node2D = null
	var offset: Vector2 = Vector2.ZERO
var attack_queue: Array[Attack]
const ATTACK_QUEUE_INTERVAL: float = 0.25
var pop_attack_queue_timer: float = 0.0
var attack_timer: float = randf_range(4.0, 8.0)
const ATTACKS = [ 
	"shock_line", "shock_circle", "shock_random", "random", "spiral", 
	"target", "target",
	"orbital_strike", "orbital_strike"
]

func _ready() -> void:
	lawn.boss_count += 1
	super._ready()
	$SpawnParticles.emitting = true

func explode() -> void:
	var explosion: Explosion = explosion_scene.instantiate()
	explosion.global_position = $AnimatedSprite2D.global_position
	explosion.scale *= 0.6
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
	
	lawn.bosses_killed += 1
	queue_free()

func calculate_velocity() -> Vector2:
	if !attack_queue.is_empty():
		return Vector2.ZERO
	return super.calculate_velocity()

func get_animation() -> String:
	if attack_queue.size() > 1:
		return "attack"
	return "default"

# Prevent the enemy from shooting if their bullets are just going to end up
# colliding with a hedge tile
func can_shoot() ->  bool:
	var tile_pos: Vector2i = Vector2i(
		int($BulletSpawnPoint.global_position.x / lawn.tile_size.x),
		int($BulletSpawnPoint.global_position.y / lawn.tile_size.y)
	)
	for dx in range(-1, 1 + 1):
		for dy in range(-1, 1 + 1):
			var x: int = tile_pos.x + dx
			var y: int = tile_pos.y + dy
			if LawnGenerationUtilities.is_hedge(lawn.get_tile(x, y)):
				return false
	return true

func shoot() -> void:
	if !can_shoot():
		return
	if !attack_queue.is_empty():
		return
	$Shoot.play()
	shoot_bullet(-PI / 6.0)
	shoot_bullet()
	shoot_bullet(PI / 6.0)

func pop_attack_queue(delta: float) -> void:
	if attack_queue.is_empty():
		return
	if pop_attack_queue_timer > 0.0:
		pop_attack_queue_timer -= delta
	while !attack_queue.is_empty() and pop_attack_queue_timer <= 0.0:
		var attack: Attack = attack_queue.pop_front()
		if attack.node == null and !can_shoot():
			continue
		elif attack.node == null:
			$Shoot.play()
			shoot_bullet()
			pop_attack_queue_timer = ATTACK_QUEUE_INTERVAL
			break

		if attack.node is EnemyBullet and !can_shoot():
			continue
		if attack.node is ElectricShock:
			$Zap.play()
		else:
			$Shoot.play()
		attack.node.global_position = $BulletSpawnPoint.global_position + attack.offset
		lawn.add_child(attack.node)
		pop_attack_queue_timer = ATTACK_QUEUE_INTERVAL

func start_attack() -> void:
	var attack_type: String = ATTACKS[randi() % ATTACKS.size()]
	match attack_type:
		"shock_line":
			var player_dist: float = (player.global_position - global_position).length()
			var dist: float = 0.0
			var dir: Vector2 = (player.global_position - global_position).normalized()
			while player_dist > 0.0:
				var pos: Vector2 = dist * dir
				var attack: Attack = Attack.new()
				attack.node = electric_shock_scene.instantiate()
				attack.node.can_damage_player = true
				attack.offset = pos	
				attack_queue.push_back(attack)
				player_dist -= 16.0
				dist += 32.0
		"shock_circle":
			var player_angle: float = (player.global_position - global_position).angle()
			var count: int = randi_range(8, 10)
			var angle_step: float = 2.0 * PI / float(count)
			for i in range(count):
				var angle: float = player_angle + angle_step * float(i) + PI
				var dir: Vector2 = Vector2(cos(angle), sin(angle))
				var attack: Attack = Attack.new()
				attack.offset = 80.0 * dir
				attack.node = electric_shock_scene.instantiate()
				attack.node.can_damage_player = true
				attack_queue.push_back(attack)
		"shock_random":
			var count: int = randi_range(8, 10)
			for i in range(count):
				var dist: float = randf_range(0.0, 64.0)
				var angle: float = randf_range(0.0, 2.0 * PI)
				var dir: Vector2 = Vector2(cos(angle), sin(angle))
				var attack: Attack = Attack.new()
				attack.offset = dist * dir
				attack.node = electric_shock_scene.instantiate()
				attack.node.can_damage_player = true
				attack_queue.push_back(attack)
		"random":
			var count: int = randi_range(12, 16)
			for i in range(count):
				var attack: Attack = Attack.new()
				var bullet: EnemyBullet = bullet_scene.instantiate()
				var angle: float = randf_range(0.0, 2.0 * PI)
				bullet.dir = Vector2(cos(angle), sin(angle))
				attack.node = bullet
				attack_queue.push_back(attack)
		"spiral":
			var count: int = randi_range(36, 48)
			var angle: float = randf_range(0.0, 2.0 * PI)
			for i in range(count):
				var attack: Attack = Attack.new()
				var bullet: EnemyBullet = bullet_scene.instantiate()
				bullet.dir = Vector2(cos(angle), sin(angle))
				attack.node = bullet
				attack_queue.push_back(attack)
				angle += PI / 10.0
		"target":
			for i in range(40):
				attack_queue.push_back(Attack.new())
		"orbital_strike":
			var attack: Attack = Attack.new()
			attack.offset = player.global_position + player.velocity * 2.5 - $BulletSpawnPoint.global_position
			attack.node = orbital_strike_scene.instantiate()
			attack_queue.push_back(attack)
		_:
			pass

func _process(delta: float) -> void:
	if spawn_timer > 0.0:
		modulate.a = (cos(5.0 * PI * spawn_timer) + 1.0) / 2.0
	else:
		modulate.a = 1.0
	super._process(delta)
	if spawn_timer > 0.0 or health <= 0 or player.health <= 0:
		return
	pop_attack_queue(delta)
	if attack_queue.is_empty():
		attack_timer -= delta
	if attack_timer <= 0.0:
		attack_timer = randf_range(4.0, 8.0)
		start_attack()

func _on_bullet_hitbox_area_entered(body: Node2D) -> void:
	# Enemy is immune to explosions
	if body.get_parent() is Explosion:
		return
	if body is ElectricShock:
		if body.can_damage_player:
			return
	super._on_bullet_hitbox_area_entered(body)

func _on_hit() -> void:
	if randi() % 2 == 0:
		call_deferred("shoot_bullet")
		$Shoot.play()
