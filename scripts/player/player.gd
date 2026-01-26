class_name Player

extends CharacterBody2D

const LAWNMOWER_PATH: String = "/root/Main/Lawn/Lawnmower"
@onready var lawnmower: Lawnmower = get_node_or_null(LAWNMOWER_PATH)
@onready var default_sprite_pos: Vector2 = $AnimatedSprite2D.position
@export var water_gun: Sprite2D
@export var eggplant_bullet_scene: PackedScene

const NORMAL_SPEED: float = 60.0
const LAWN_MOWER_SPEED: float = NORMAL_SPEED * 0.75
const HEDGE_COLLISION_SPEED: float = NORMAL_SPEED * 0.07
var speed: float = NORMAL_SPEED

var dir: String = "down"
var interact_text: String = ""
var can_pick_up_water_gun: bool = false
var can_pick_up_lawnmower: bool = false
# The target velocity of the player based on the controls the player is pressing,
# this might not be equal to `velocity` since the player may be walking into a wall
var target_velocity: Vector2 = Vector2.ZERO
# Whether the player just dropped the lawn mower
var dropped: bool = false
var can_move: bool = true

var max_health_level: int = 0
var health: int = get_max_health()
# For displaying a red flash whenever the player takes damage
const DAMAGE_COOLDOWN: float = 1.25
var damage_timer: float = 0.0
# If this is above 0, then that means that the player hit a hedge with a lawn
# mower and should be slowed down
var hedge_collision_timer: float = 0.0
const HEDGE_TIMER: float = 0.3
# Control whether the player is on fire or not
var fire_timer: float = 0.0
var fire_damage_timer: float = 0.0
const FIRE_DAMAGE_INTERVAL: float = 0.2
var status_effects: Dictionary = {}
# Eggplant
var eggplant_timer: float = 0.0
const EGGPLANT_INTERVAL: float = 0.5

func get_max_health() -> int:
	match max_health_level:
		0:
			return 80
		_:
			return 100

func _ready() -> void:
	$Lawnmower.hide()

# Returns a value between 0.0 and 1.0
func get_hp_perc() -> float:
	if health <= 0:
		return 0.0
	return float(health) / float(get_max_health())

func reset_health() -> void:
	health = get_max_health()
	damage_timer = 0.0

func activate_hedge_timer() -> void:
	hedge_collision_timer = HEDGE_TIMER

func heal(amt: int) -> void:
	health += amt
	health = min(health, get_max_health())

# Apply damage to the player using this function
func damage(amt: int) -> void:
	if amt <= 0:
		return
	health -= amt
	health = max(health, 0)
	damage_timer = DAMAGE_COOLDOWN
	if health > 0:
		$/root/Main.play_sfx("Hurt", true)

# Returns a value between 0.0 and 1.0
func get_damage_timer_perc() -> float:
	return damage_timer / DAMAGE_COOLDOWN

func get_dir_vec() -> Vector2:
	match dir:
		"left":
			return Vector2.LEFT
		"right":
			return Vector2.RIGHT
		"down":
			return Vector2.DOWN
		"up":
			return Vector2.UP
	return Vector2.ZERO

func set_animation() -> void:
	if target_velocity.y < 0.0:
		dir = "up"
	elif target_velocity.y > 0.0:
		dir = "down"
	
	if target_velocity.x < 0.0:
		dir = "left"
	elif target_velocity.x > 0.0:
		dir = "right"
	
	var state = "walk"
	if velocity.length() == 0.0:
		state = "idle"
	var animation = state + "_" + dir
	$AnimatedSprite2D.animation = animation

func set_lawn_mower_pos() -> void:
	if !lawn_mower_active():
		$Lawnmower.position = Vector2(0.0, -7.0)
		return

	match dir:
		"left":
			$Lawnmower.position = Vector2(-2.5, -7.0)
		"right":
			$Lawnmower.position = Vector2(2.5, -7.0)
		"down":
			$Lawnmower.position = Vector2(0.0, -8.0)
		"up":
			$Lawnmower.position = Vector2(0.0, -12.0)

func get_lawn_mower_dir_offset() -> Vector2:
	match dir:
		"left":
			return -(get_dir_vec() * 12.0 + Vector2(0.5, -7.0)) + $Lawnmower.position
		"right":
			return -(get_dir_vec() * 12.0 + Vector2(-0.5, -7.0)) + $Lawnmower.position
		"down":
			return $Lawnmower.position + Vector2(0.0, 2.0)
		"up":
			return -get_dir_vec() * 12.0 + $Lawnmower.position
	return Vector2.ZERO

func update_lawn_mower() -> void:
	$AnimatedSprite2D.position = default_sprite_pos
	$ReleaseCollisionChecker.position = Vector2(0.0, 0.0)
	set_lawn_mower_pos()
	if !lawn_mower_active():
		return

	$Lawnmower.animation = dir

	# Set the position of the lawn mower
	$AnimatedSprite2D.position += get_lawn_mower_dir_offset()
	$ReleaseCollisionChecker.position += get_lawn_mower_dir_offset()
	
	# Set the z index of the lawn mower
	if dir == "up":
		$Lawnmower.z_index = -1
	else:
		$Lawnmower.z_index = 0

	# Set the shadow of the lawn mower
	for shadow in $Lawnmower/Shadows.get_children():
		shadow.hide()

	match dir:
		"left":
			$Lawnmower/Shadows/ShadowLeft.show()
		"right":
			$Lawnmower/Shadows/ShadowRight.show()
		"down":
			$Lawnmower/Shadows/ShadowDown.show()
		"up":
			$Lawnmower/Shadows/ShadowUp.show()

# Returns the global position of the lawn mower
func get_lawn_mower_position() -> Vector2:
	return $Lawnmower.global_position

func pick_up_lawn_mower() -> void:
	if $WaterGun.visible:
		return

	if !can_pick_up_lawnmower:
		return

	if !lawnmower.visible:
		return

	if $PickupCollisionChecker.colliding():
		return

	if lawnmower.cooldown > 0.0:
		return

	if Input.is_action_just_pressed("interact"):
		$/root/Main.play_sfx("LawnMowerStart")
		position -= get_lawn_mower_dir_offset()
		lawnmower.hide()
		$Lawnmower.show()
		var prev_pos = lawnmower.global_position
		set_lawn_mower_pos()
		var diff = $Lawnmower.global_position - prev_pos
		position -= diff
		position.y += $Lawnmower.position.y
		if dir == "up":
			position.y += 6.0
	
func too_close_to_drop_mower() -> bool:
	if $Lawnmower/CollisionChecker.colliding():
		return true
	if $ReleaseCollisionChecker.colliding():
		return true
	return false

# Returns true if the player 'dropped' the lawn mower, false otherwise
func drop_lawn_mower() -> bool:
	if !lawn_mower_active():
		return false
	if $ReleaseCollisionChecker.colliding() and health > 0:
		return false
	if $Lawnmower/CollisionChecker.colliding() and health > 0:
		return false
	if Input.is_action_just_pressed("interact") or health <= 0:
		$/root/Main.play_sfx("TurnOffMower")
		lawnmower.position = global_position + $Lawnmower.position
		lawnmower.position.y -= $Lawnmower.position.y
		if dir == "up":
			lawnmower.position.y -= 6.0
		lawnmower.show()
		lawnmower.cooldown = 0.5
		match dir:
			"left", "right":
				lawnmower.dir = dir
			_:
				if randi() % 2 == 0:
					lawnmower.dir = "left"
				else:
					lawnmower.dir = "right"
		$Lawnmower.hide()
		position = global_position + get_lawn_mower_dir_offset()
		return true
	return false

func take_fire_damage(delta: float) -> void:
	var fire_particles: Node2D = get_node_or_null("FireParticles")
	if fire_timer <= 0.0:
		if fire_particles:
			fire_particles.queue_free()
		return
	fire_timer = max(fire_timer - delta, 0.0)
	if !fire_particles:
		add_child(Fire.fire_particles.instantiate())
	else:
		if lawn_mower_active():
			fire_particles.scale = Vector2(0.7, 0.7)
		else:
			fire_particles.scale = Vector2(0.5, 0.5)
	fire_damage_timer -= delta
	if fire_damage_timer <= 0.0 or fire_timer <= 0.0:
		fire_damage_timer = FIRE_DAMAGE_INTERVAL
		damage(2)

func shoot_eggplant_bullet(delta: float) -> void:
	if get_status_effect_time("eggplant") <= 0.0:
		return
	eggplant_timer -= delta
	if eggplant_timer > 0.0:
		return
	var lawn: Lawn = get_node_or_null("/root/Main/Lawn")
	if lawn == null:
		return
	if !$Pop.playing:
		$Pop.play()
	eggplant_timer = EGGPLANT_INTERVAL
	var count: int = randi_range(4, 8)
	var offset: float = randf_range(0.0, 2.0 * PI)
	for i in range(count):
		var eggplant_bullet = eggplant_bullet_scene.instantiate()
		var angle: float = 2.0 * PI / count * i + offset
		var bullet_dir = Vector2(cos(angle), sin(angle))
		eggplant_bullet.position = get_sprite_pos()
		eggplant_bullet.dir = bullet_dir
		lawn.add_child(eggplant_bullet)

func _process(delta: float) -> void:
	update_status_effects(delta)
	visible = health > 0
	if health <= 0:
		if lawn_mower_active():
			drop_lawn_mower()
		$WaterGun.hide()
		return

	take_fire_damage(delta)
	shoot_eggplant_bullet(delta)

	update_enemy_arrow()
	update_lawn_mower_arrow()

	$CollisionShape2D.disabled = lawn_mower_active()
	$LawnmowerHitbox.disabled = !lawn_mower_active()
	$LawnmowerUpHitbox.disabled = !(lawn_mower_active() and dir == "up")
	$PickupCollisionChecker/LawnmowerUpHitbox.disabled = (dir == "up")
	$PickupCollisionChecker.position = -get_lawn_mower_dir_offset()

	# Drop lawn mower
	dropped = false
	if mower_exists():
		dropped = drop_lawn_mower()
	# Attempt to pick up lawn mower
	if mower_exists() and !dropped:
		pick_up_lawn_mower()

	# Update lawn mower
	update_lawn_mower()

	# Set speed
	if lawn_mower_active() and hedge_collision_timer > 0.0:
		speed = HEDGE_COLLISION_SPEED
	elif lawn_mower_active():
		speed = LAWN_MOWER_SPEED
	else:
		speed = NORMAL_SPEED
	if get_status_effect_time("speed") > 0.0:
		speed *= 1.5
	
	set_animation()
	
	damage_timer -= delta
	damage_timer = max(damage_timer, 0.0)
	hedge_collision_timer -= delta
	hedge_collision_timer = max(hedge_collision_timer, 0.0)

func _physics_process(_delta: float) -> void:
	if health <= 0:
		return

	velocity = Vector2.ZERO	

	# movement
	# don't move when menu is open
	if !$/root/Main/HUD.npc_menu_open() and !$/root/Main/HUD.quest_screen_open() and can_move:
		if Input.is_action_pressed("move_up"):
			velocity.y -= 1.0
		if Input.is_action_pressed("move_down"):
			velocity.y += 1.0
		if Input.is_action_pressed("move_left"):
			velocity.x -= 1.0
		if Input.is_action_pressed("move_right"):
			velocity.x += 1.0
	
	if velocity.x == 0.0 and velocity.y < 0.0:
		if $UpCollisionChecker.colliding() and lawn_mower_active():
			velocity.y = 0.0
	
	# Normalize player velocity
	if velocity.length() > 0.0:
		velocity /= velocity.length()
	velocity *= speed	
	target_velocity = velocity
	
	var prev_position: Vector2 = global_position 
	move_and_slide()
	# if we just dropped the lawn mower, then move the lawn mower along with the
	# player if the player is moving/just got pushed via a collision with a wall.
	if dropped:
		lawnmower.position += (global_position - prev_position)

func mower_exists() -> bool:
	lawnmower = get_node_or_null(LAWNMOWER_PATH)
	return lawnmower != null and lawnmower.is_inside_tree()

func _on_interact_zone_body_entered(body: Node2D) -> void:
	if body.is_in_group("water_gun_item"):
		can_pick_up_water_gun = true
	if body.is_in_group("lawnmower"):
		can_pick_up_lawnmower = true

func _on_interact_zone_body_exited(body: Node2D) -> void:
	if body.is_in_group("water_gun_item"):
		can_pick_up_water_gun = false
	if body.is_in_group("lawnmower"):
		can_pick_up_lawnmower = false

func enable_water_gun() -> void:
	$WaterGun.show()

func disable_water_gun() -> void:
	$WaterGun.hide()

func lawn_mower_active() -> bool:
	return $Lawnmower.visible

# Returns global position of the animated sprite
func get_sprite_pos() -> Vector2:
	return $AnimatedSprite2D.position + position

func get_lawn_mower_rect() -> Rect2:
	var r: Rect2 = Rect2(0, 0, 0, 0)
	var collision: CollisionShape2D
	match dir:
		"up":
			collision = $Lawnmower/Area2D/Up
		"down":
			collision = $Lawnmower/Area2D/Down
		"right":
			collision = $Lawnmower/Area2D/Right
		"left":
			collision = $Lawnmower/Area2D/Left
		_:
			return r
	r = collision.shape.get_rect()
	r.position = collision.global_position - r.size / 2.0
	return r

func get_tile_position() -> Vector2i:
	var lawn = get_node_or_null("/root/Main/Lawn")
	if lawn == null:
		return Vector2i(0, 0)
	var pos: Vector2 = global_position
	if lawn_mower_active():
		pos += get_lawn_mower_dir_offset()
	return Vector2i(floor(pos.x / lawn.tile_size.x), floor(pos.y / lawn.tile_size.y))

func save() -> Dictionary:
	var data = {
		"max_health_level" : get_max_health(),
	}
	return data

func reset() -> void:
	status_effects.clear()
	$NeighborArrow.point_to = ""
	max_health_level = 0
	fire_timer = 0.0

func update_enemy_arrow() -> void:
	var lawn: Lawn = get_node_or_null("/root/Main/Lawn")
	if lawn == null:
		$EnemyArrow.point_to = ""
		return

	if lawn.cut_grass_tiles < lawn.total_grass_tiles:
		$EnemyArrow.point_to = ""
		return

	$EnemyArrow.point_to = ""
	var min_dist: float = -1.0
	for path: NodePath in lawn.weeds:
		var weed: WeedEnemy = get_node_or_null(path)
		if weed == null:
			continue
		var dist: float = (weed.global_position - global_position).length()
		if dist < min_dist or min_dist < 0.0:
			$EnemyArrow.point_to = path
			min_dist = dist

func update_lawn_mower_arrow() -> void:
	var lawn: Lawn = get_node_or_null("/root/Main/Lawn")
	if lawn == null:
		return

	if lawn.cut_grass_tiles < lawn.total_grass_tiles:
		$LawnmowerArrow.point_to = "/root/Main/Lawn/Lawnmower"
		return

	$LawnmowerArrow.point_to = ""

func get_status_effect_time(id: String) -> float:
	if id in status_effects:
		return status_effects[id]
	return 0.0

func set_status_effect_time(id: String, time: float) -> void:
	status_effects[id] = time

func update_status_effects(delta: float) -> void:
	if health <= 0 and status_effects.size() > 0:
		status_effects.clear()
		return

	for key in status_effects.keys():
		var time: float = status_effects[key]
		time -= delta
		status_effects[key] = time
		if status_effects[key] <= 0.0:
			status_effects.erase(key)
