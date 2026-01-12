extends MobileEnemy

@export var blood_scene: PackedScene
@export var wasp_scene: PackedScene
@onready var default_contact_damage_pos: Vector2 = $ContactDamageZone.position
const CHANGE_DIR_INTERVAL: float = 0.1
var change_dir_timer: float = 0.0
var idle_timer: float = 0.0
var time_until_idle: float = randf_range(4.0, 8.0)
var shoot_mode: String = "normal"
var change_shoot_mode_timer: float = randf_range(5.0, 8.0)
const SHOOT_MODES_PHASE1: Array[String] = [ "normal", "multi", "random" ]
const SHOOT_MODES_PHASE2: Array[String] = [ "multi", "random", "spawn", "circle" ]
@onready var default_bullet_cooldown: float = bullet_cooldown

func in_shooting_range() -> bool:
	return (player.global_position - global_position).length() < max_chase_distance

func _ready() -> void:
	$AnimatedSprite2D.animation = "spawn"
	super._ready()

func explode() -> void:
	var blood: GPUParticles2D = blood_scene.instantiate()
	blood.global_position = global_position
	blood.scale *= 2.5
	$/root/Main/Lawn.add_child(blood)
	super.explode()
	queue_free()

func set_shoot_cooldown() -> void:
	match shoot_mode:
		"multi":
			bullet_cooldown = default_bullet_cooldown * 1.5
		"random":
			bullet_cooldown = default_bullet_cooldown * 0.12
		"spawn":
			bullet_cooldown = default_bullet_cooldown * 3.9
		"circle":
			bullet_cooldown = default_bullet_cooldown * 0.3
		_:
			bullet_cooldown = default_bullet_cooldown

func shoot() -> void:
	idle_timer = 0.25
	match shoot_mode:
		"normal":
			shoot_bullet()
		"multi":
			var count: int = randi_range(2, 4)
			for i in range(count):
				shoot_bullet(PI / 4.0 * (float(i) - float(count - 1) / 2))
		"random":
			var offset: float = randf_range(-PI / 3.0, PI / 3.0)
			shoot_bullet(offset)
		"circle":	
			var count: int = randi_range(3, 7)
			var offset: float = randf() * 2.0 * PI
			for i in range(count):
				shoot_bullet(2.0 * PI / float(count) * i + offset)
		"spawn":
			Spawning.try_spawning_around_point(
				lawn,
				lawn.get_node("MobileEnemies"),
				global_position,
				wasp_scene,
				1.0,
				4.0,
				2
			)
		_:
			pass

func calculate_velocity() -> Vector2:
	if idle_timer > 0.0:
		return Vector2.ZERO
	if shoot_mode == "random" or shoot_mode == "circle":
		return Vector2.ZERO
	return super.calculate_velocity()

func get_animation() -> String:
	if spawn_timer > 0.0:
		return "spawn"
	if health <= int(max_health / 2.0):
		return "phase2"
	return "default"

func _process(delta: float) -> void:
	$SpawnShadow.visible = spawn_timer > 0.0
	$Shadow.visible = !$SpawnShadow.visible

	super._process(delta)
	
	change_dir_timer -= delta
	if change_dir_timer < 0.0:
		set_sprite_dir()
		change_dir_timer = CHANGE_DIR_INTERVAL

	var diff = player.global_position - global_position
	if diff.length() > 0.0:
		diff = diff.normalized()
	$ContactDamageZone.position = default_contact_damage_pos + diff * 8.0
	
	idle_timer -= delta
	idle_timer = max(0.0, idle_timer)
	if idle_timer <= 0.0:
		time_until_idle -= delta
	var dist_to_player: float = (player.global_position - global_position).length()
	if time_until_idle <= 0.0:
		idle_timer = randf_range(0.5, 2.0)
		time_until_idle = randf_range(4.0, 8.0)
	elif dist_to_player <= min_chase_distance:
		idle_timer = 0.5

	change_shoot_mode_timer -= delta
	if change_shoot_mode_timer <= 0.0:
		change_shoot_mode_timer = randf_range(5.0, 8.0)
		idle_timer = 1.5
		if health > int(max_health / 2.0):
			shoot_mode = SHOOT_MODES_PHASE1[randi() % len(SHOOT_MODES_PHASE1)]
		else:
			shoot_mode = SHOOT_MODES_PHASE2[randi() % len(SHOOT_MODES_PHASE2)]
	set_shoot_cooldown()

func _on_hit() -> void:
	if randi() % 2 == 0:
		idle_timer = max(idle_timer, 0.75)
	if randi() % 3 == 0:
		call_deferred("shoot_bullet")
