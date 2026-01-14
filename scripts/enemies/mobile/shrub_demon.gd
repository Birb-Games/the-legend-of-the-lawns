extends MobileEnemy

@onready var default_contact_damage_pos: Vector2 = $ContactDamageZone.position

var idle_timer: float = 0.0
var engaged: bool = false

func _ready() -> void:
	super._ready()
	$AnimatedSprite2D.animation = "spawn"

func in_shooting_range() -> bool:
	var player_dist: float = (player.global_position - global_position).length()
	return player_dist < max_chase_distance * 0.7 and player_dist > min_chase_distance

func shoot() -> void:
	if randi() % 2 == 0:
		return
	idle_timer = 0.5 + randf() * 0.5
	super.shoot()

func calculate_velocity() -> Vector2:
	if idle_timer > 0.0:
		return Vector2.ZERO
	return super.calculate_velocity()

func get_animation() -> String:
	if spawn_timer > 0.0:
		return "spawn"

	if calculate_velocity().length() > 0.0:	
		return "walking"
	else:
		if $ContactDamageZone.can_attack_player():
			return "attack"
		return "idle"

func _process(delta: float) -> void:
	$Shadow.visible = spawn_timer <= 0.0
	$SpawnShadow.visible = !$Shadow.visible

	super._process(delta)
	var diff = player.global_position - global_position
	if diff.length() > 0.0:
		diff = diff.normalized()
	$ContactDamageZone.position = default_contact_damage_pos + diff * 8.0
	idle_timer -= delta
	idle_timer = max(0.0, idle_timer)

func _on_hit() -> void:
	if !engaged:
		max_chase_distance *= 2.5
	engaged = true
