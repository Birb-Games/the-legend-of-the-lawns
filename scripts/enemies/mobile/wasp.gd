extends MobileEnemy

class_name Wasp

@export var blood_scene: PackedScene
@onready var default_contact_damage_pos: Vector2 = $ContactDamageZone.position
const CHANGE_DIR_INTERVAL: float = 0.1
var change_dir_timer: float = 0.0
var idle_timer: float = 0.0
var time_until_idle: float = randf_range(4.0, 8.0)

func in_shooting_range() -> bool:
	return (player.global_position - global_position).length() < max_chase_distance

func _ready() -> void:
	$AnimatedSprite2D.animation = "spawn"
	super._ready()

func explode() -> void:
	var blood: GPUParticles2D = blood_scene.instantiate()
	blood.global_position = global_position
	blood.scale *= 1.25
	$/root/Main/Lawn.add_child(blood)
	queue_free()

func shoot() -> void:
	idle_timer = randf_range(0.3, 0.6)
	super.shoot()

func calculate_velocity() -> Vector2:
	if idle_timer > 0.0:
		return Vector2.ZERO
	return super.calculate_velocity()

func get_animation() -> String:
	if spawn_timer > 0.0:
		return "spawn"
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

func _on_hit() -> void:
	if randi() % 2 == 0:
		idle_timer = max(idle_timer, 0.75)

func damage(amt: int) -> void:
	if randi() % 4 == 0:
		return
	super.damage(amt)
