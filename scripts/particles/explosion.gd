extends OneShotParticles

class_name Explosion

@export var damage: int = 0
@export var can_damage_mobile: bool = false
@export var can_damage_plants: bool = false

var hit: Dictionary

func calculate_damage(pos: Vector2) -> int:
	var dist: float = (pos - global_position).length()
	var max_dist: float = $DamageZone/CollisionShape2D.shape.radius * global_scale.x
	var damage_applied: int 
	if dist / max_dist < 0.25:
		return damage
	else:
		var sample: float = 1.0 - (dist / max_dist - 0.25) / 0.75
		damage_applied = int(ceil(lerp(float(damage) / 2.0, float(damage), sample)))
		return clamp(damage_applied, int(ceil(damage / 2.0)), damage)

func _on_damage_zone_body_entered(body: Node2D) -> void:
	if body.get_path() in hit:
		return
	hit[body.get_path()] = true
	
	# Apply damage
	var damage_applied = calculate_damage(body.global_position)
	if body is Player:
		body.damage(damage_applied)

func _on_damage_zone_area_entered(area: Area2D) -> void:
	if area.get_path() in hit:
		return
	hit[area.get_path()] = true

	var damage_applied = calculate_damage(area.global_position)
	if area is WeedEnemy:
		if can_damage_plants:
			area.health -= damage_applied
	elif area is FlowerEnemy:
		if can_damage_plants:
			area.health -= damage_applied
			area.stun()

