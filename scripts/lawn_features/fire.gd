extends Area2D

class_name Fire

@export var permanent: bool = false

static var fire_particles: PackedScene = preload("uid://dt374voqtyp4c")
static var fire_scene: PackedScene = preload("uid://bodmljl34l6om")
var colliding: Dictionary
var can_spread_to: Dictionary

var lifetime: float = 1.0
@onready var total_time: float = randf_range(10.0, 20.0)
var remove_lifetime_amt: float = 0.0
const FIRE_DURATION: float = 3.0
var hedge_destruction_timer: float = 9.0
var hedge_spread_timer: float = 6.0
var enemy_spread_timer: float = 3.0
var can_spread: bool = true
const FIRE_DAMAGE_INTERVAL: float = 1.0
var fire_damage_timer: float = FIRE_DAMAGE_INTERVAL

func has_fuel() -> bool: 
	var lawn: Lawn = $/root/Main/Lawn
	var tile_x: int = int(floor(global_position.x / lawn.tile_size.x))
	var tile_y: int = int(floor(global_position.y / lawn.tile_size.y))
	var tile_pos: Vector2i = Vector2i(tile_x, tile_y)
	if LawnGenerationUtilities.is_hedge(tile_pos) and lifetime > 0.2:
		return true
	for body in colliding:
		if body is WeedEnemy or body is FlowerEnemy:
			return true
	return permanent

static func tile_has_space(lawn: Lawn, x: int, y: int) -> bool:
	for dx in range(-1, 1 + 1):
		for dy in range(-1, 1 + 1):
			if abs(dx) == abs(dy):
				continue
			var tile = lawn.get_tile(x + dx, y + dy)
			var is_grass: bool = LawnGenerationUtilities.is_grass(tile)
			var is_cut_grass: bool = LawnGenerationUtilities.is_cut_grass(tile)
			var is_destroyed_hedge: bool = tile == LawnGenerationUtilities.DESTROYED_HEDGE
			if is_grass or is_cut_grass or is_destroyed_hedge:
				return true
	return false

# Returns true if spread
func spread_to_hedges() -> bool:
	var lawn: Lawn = get_node_or_null("/root/Main/Lawn")
	var tile_x: int = int(floor(global_position.x / lawn.tile_size.x))
	var tile_y: int = int(floor(global_position.y / lawn.tile_size.y))
	var count: int = 0
	for dx in range(-1, 1 + 1):
		for dy in range(-1, 1 + 1):
			var tile = lawn.get_tile(tile_x + dx, tile_y + dy)
			# Make sure that the tile is a hedge
			if !LawnGenerationUtilities.is_hedge(tile):
				continue
			if !tile_has_space(lawn, tile_x + dx, tile_y + dy):
				continue
			# Make sure that the hedge has space around it
			if randi() % 4 == 0:
				var fire: Fire = fire_scene.instantiate()
				fire.global_position = Vector2(float(tile_x + dx) + 0.5, float(tile_y + dy) + 0.5)
				fire.global_position.x *= lawn.tile_size.x
				fire.global_position.y *= lawn.tile_size.y
				lawn.add_child(fire)
				count += 1
			if count >= 3:
				return true
	return count > 0

func _process(delta: float) -> void:
	var lawn: Lawn = $/root/Main/Lawn
	var tile_x: int = int(floor(global_position.x / lawn.tile_size.x))
	var tile_y: int = int(floor(global_position.y / lawn.tile_size.y))

	# Clear out any invalid instances
	for key in colliding.keys():
		if is_instance_valid(colliding[key]):
			continue
		colliding.erase(key)
	for key in can_spread_to.keys():
		if is_instance_valid(can_spread_to[key]):
			continue
		colliding.erase(key)
	
	# Slowly die over time, unless this is set to be a 'permanent' fire or
	# we have fuel
	if !has_fuel():
		lifetime -= delta / total_time
	if lifetime <= 0.6:
		$FireParticles/Smoke.emitting = false
	if lifetime <= 0.0:
		queue_free()
		return
	if remove_lifetime_amt >= 0.0:
		lifetime -= delta * 4.0 / total_time
		remove_lifetime_amt -= delta * 4.0 /total_time
	if lifetime < 0.5:
		scale = Vector2(lifetime * lifetime, lifetime * lifetime) * 4.0
	
	# Destroy hedge
	if hedge_destruction_timer > 0.0:
		hedge_destruction_timer -= delta
	elif lifetime > 0.1:
		lawn.destroy_hedge(Vector2i(tile_x, tile_y))

	if can_spread:
		hedge_spread_timer -= delta
		enemy_spread_timer -= delta
	if enemy_spread_timer <= 0.0 and can_spread and lifetime > 0.2:
		# Spread to weeds and flowers
		for enemy in can_spread_to.values():
			if randi() % 3 > 0:
				continue
			if (enemy.global_position - global_position).length() < 2.0:
				continue
			var fire: Fire = fire_scene.instantiate()
			fire.global_position = enemy.global_position
			fire.colliding[enemy.get_path()] = enemy
			lawn.add_child(fire)
			can_spread = true
		enemy_spread_timer = 1.0
	if hedge_spread_timer <= 0.0 and can_spread and lifetime > 0.2:	
		# Spread to hedges
		if spread_to_hedges():
			can_spread = false
		hedge_spread_timer = 1.0
	
	# Set things on fire
	if lifetime > 0.2:
		fire_damage_timer -= delta
		for body in colliding.values():
			if body is Player:
				body.fire_timer = FIRE_DURATION
			
			if fire_damage_timer > 0.0:
				continue
			
			# Damage enemies
			if body is WeedEnemy:
				if body.boss:
					continue
				body.health -= 1
			elif body is FlowerEnemy:
				body.health -= 1
				body.stun()
		if fire_damage_timer <= 0.0:
			fire_damage_timer = FIRE_DAMAGE_INTERVAL

func _on_area_entered(area: Area2D) -> void:
	if area is WeedEnemy:
		colliding[area.get_path()] = area
	elif area is FlowerEnemy:
		area.stun()
		colliding[area.get_path()] = area

func _on_area_exited(area: Area2D) -> void:
	if area.get_path() in colliding:
		colliding.erase(area.get_path())

func _on_body_entered(body: Node2D) -> void:
	if lifetime < 0.2:
		return
	if body is Player:
		body.damage(2)
		colliding[body.get_path()] = body

func _on_body_exited(body: Node2D) -> void:
	if body.get_path() in colliding:
		colliding.erase(body.get_path())

func _on_bullet_hitbox_area_entered(area: Area2D) -> void:
	if area is PlayerBullet:
		if area.active():
			area.explode()
			remove_lifetime_amt += 0.15

func _on_can_spread_to_area_exited(area: Area2D) -> void:
	if area.get_path() in can_spread_to:
		can_spread_to.erase(area.get_path())

func _on_can_spread_to_area_entered(area: Area2D) -> void:	
	if area is WeedEnemy or area is FlowerEnemy:
		if area is WeedEnemy:
			if area.boss:
				return
		can_spread_to[area.get_path()] = area
