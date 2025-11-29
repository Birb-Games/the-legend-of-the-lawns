extends MobileEnemy

@onready var default_contact_damage_pos: Vector2 = $ContactDamageZone.position

func get_animation() -> String:
	if calculate_velocity().length() > 0.0:
		return "walking"
	else:
		return "idle"

func _process(delta: float) -> void:
	super._process(delta)
	var diff = player.global_position - global_position
	if diff.length() > 0.0:
		diff = diff.normalized()
	$ContactDamageZone.position = default_contact_damage_pos + diff * 8.0
