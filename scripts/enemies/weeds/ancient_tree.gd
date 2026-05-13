extends WeedEnemy

class Attack:
	var angle_offset: float = 0.0
	var target_player: bool = true
	var delay: float = 0.0
	func _init(angle: float, target: bool, time: float) -> void:
		delay = time
		angle_offset = angle
		target_player = target

@export var explosion_scene: PackedScene
@export var fire_scene: PackedScene
@export var resist_particle_scene: PackedScene
@onready var lawn: Lawn = $/root/Main/Lawn
@onready var hud = $/root/Main/HUD
var hostile_timer: float = 2.0
const MIN_ATTACK_TIME: float = 4.0
const MAX_ATTACK_TIME: float = 8.0
@onready var attack_timer: float = randf_range(MIN_ATTACK_TIME, MAX_ATTACK_TIME)
var attack_queue: Array[Attack] = []
var ATTACKS: Array = [
	[],
	[ "target", "random" ],
	[ "target", "random", "spiral", "bullet_wave" ],
	[ "target", "random", "spiral", "bullet_wave", "bullet_wave_circle" ]
]
var roar_timer: float = 4.0

func cut_scene_running() -> bool:
	if lawn is FinalBossLawn:
		return lawn.intro or lawn.begin_dialog
	return false

# Returns the current phase the boss is in
# 0 = the lawn hasn't been entirely cut yet, it is invulnerable but doesn't
# shoot that many bullets
# 1 = Half the lawn is cut, still invulnerable to damage, will have occasional
# large attacks
# 2 = vulnerable to damage and shoots bullets in a ring - has occasional attacks
# that shoot out a lot of bullets
# 3 = similar to phase 1 but shoots bullets even more aggressively and attacks
# are much stronger
func get_phase() -> int:
	if lawn.cut_grass_tiles * 2 < lawn.total_grass_tiles:
		return 0
	elif lawn.cut_grass_tiles < lawn.total_grass_tiles:
		return 1
	
	if health * 2 >= max_health:
		return 2
	else:
		return 3

func explode() -> void:
	lawn.weeds_killed += 1
	Sfx.play_at_pos(global_position, "explosion", lawn)
	var explosion: Explosion = explosion_scene.instantiate()
	explosion.scale *= 0.6
	explosion.damage = 0
	explosion.modulate = Color.PURPLE
	explosion.global_position = $AnimatedSprite2D.global_position
	lawn.add_child(explosion)

	# Add fire
	var fire: Fire = fire_scene.instantiate()
	fire.global_position = $AnimatedSprite2D.global_position
	lawn.add_child(fire)
	for i in range(24):
		var dist: float = randf_range(1.0, 4.0)
		var angle: float = randf_range(0.0, 2.0 * PI)
		var dir: Vector2 = Vector2(cos(angle), sin(angle))
		var fire_position: Vector2 = $AnimatedSprite2D.global_position + dist * dir * lawn.tile_size
		var tile_x: int = int(floor(fire_position.x / lawn.tile_size.x))
		var tile_y: int = int(floor(fire_position.y / lawn.tile_size.y))
		if !(Vector2i(tile_x, tile_y) in lawn.valid_spawn_tiles):
			continue
		fire = fire_scene.instantiate()
		fire.global_position = fire_position
		lawn.add_child(fire)
	queue_free()

func shoot() -> void:
	if hostile_timer > 0.0:
		return

	match get_phase():
		0:
			var bullet_count: int = randi_range(3, 6)
			for i in range(bullet_count):
				var offset = PI / 5.0 * (float(i) - float(bullet_count - 1) / 2.0)
				shoot_bullet(offset)
		1:
			var bullet_count: int = randi_range(5, 7)
			for i in range(bullet_count):
				var offset = PI / 6.0 * (float(i) - float(bullet_count - 1) / 2.0)
				shoot_bullet(offset)
		2:
			var bullet_count: int = randi_range(6, 9)
			for i in range(bullet_count):
				var offset = 2.0 * PI / float(bullet_count) * (float(i) - float(bullet_count - 1) / 2.0)
				shoot_bullet(offset)
		3:
			var bullet_count: int = randi_range(8, 12)
			for i in range(bullet_count):
				var offset = 2.0 * PI / float(bullet_count) * (float(i) - float(bullet_count - 1) / 2.0)
				shoot_bullet(offset)
		_:
			pass

func damage(amt: int) -> void:
	if get_phase() <= 1:
		var resist = resist_particle_scene.instantiate()
		resist.global_position = global_position
		lawn.add_child(resist)
		return
	super.damage(amt)

func start_attack() -> void:
	if ATTACKS[get_phase()].is_empty():
		return
	var size: int = ATTACKS[get_phase()].size()
	var random_attack: String = ATTACKS[get_phase()][randi() % size]
	match random_attack:
		"target":
			var count: int = randi_range(24, 40)
			for i in range(count):
				attack_queue.push_back(Attack.new(0.0, true, 0.2))
		"random":
			var count: int = randi_range(40, 60)
			for i in range(count):
				attack_queue.push_back(Attack.new(randf_range(0.0, 2.0 * PI), false, 0.05))
		"spiral":
			var count: int = randi_range(40, 60)
			var angle: float = randf_range(0.0, 2.0 * PI)
			for i in range(count):
				attack_queue.push_back(Attack.new(angle, false, 0.1))
				angle += PI / 8.0
		"bullet_wave":
			var bullet_count: float = randf_range(40, 50)
			for i in range(bullet_count):
				var offset = PI / 180.0 * (float(i) - float(bullet_count - 1) / 2.0)
				shoot_bullet(offset)
		"bullet_wave_circle":
			var bullet_count: float = randf_range(60, 80)
			for i in range(bullet_count):
				var offset = 2.0 * PI / float(bullet_count) * (float(i) - float(bullet_count - 1) / 2.0)
				shoot_bullet(offset)
		_:
			pass

func pop_attack_queue(delta: float) -> void:
	if attack_queue.is_empty():
		return
	attack_queue[attack_queue.size() - 1].delay -= delta
	if attack_queue[attack_queue.size() - 1].delay < 0.0:
		var attack: Attack = attack_queue[attack_queue.size() - 1]
		if attack.target_player:
			shoot_bullet(attack.angle_offset)
		else:
			var bullet = bullet_scene.instantiate()
			var dir = Vector2(cos(attack.angle_offset), sin(attack.angle_offset))
			bullet.position = $BulletSpawnPoint.global_position
			bullet.dir = dir
			lawn.add_child(bullet)
		attack_queue.pop_back()

func _process(delta: float) -> void:
	super._process(delta)
	if hostile_timer - delta <= 0.0 and hostile_timer > 0.0:
		$Roar.play()
	if !cut_scene_running() and hostile_timer > 0.0:
		hostile_timer -= delta
	
	if get_phase() > 0 and attack_queue.is_empty():
		attack_timer -= delta
	if attack_timer < 0.0:
		start_attack()
		attack_timer = randf_range(MIN_ATTACK_TIME, MAX_ATTACK_TIME)
	pop_attack_queue(delta)

	if hostile_timer <= 0.0 and !$Roar.playing:
		roar_timer -= delta
	if roar_timer <= 0.0:
		if randi() % 2 == 0:
			$Roar.play()
		roar_timer = 4.0

func _on_hit() -> void:
	if randi() % 2 == 0:
		call_deferred("shoot")
