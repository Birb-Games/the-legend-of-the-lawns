class_name Player

extends CharacterBody2D

const LAWNMOWER_PATH: String = "/root/Main/Lawn/Lawnmower"
@onready var lawnmower: RigidBody2D = get_node_or_null(LAWNMOWER_PATH)
@export var water_gun: Sprite2D

const SPEED: float = 60.0
# const PULL_SPEED: float = SPEED / 4.0
# var speed: float = SPEED

var dir: String = "down"
# var pulling: bool = false
var interact_text: String = ""
var can_pick_up_water_gun: bool = false
var holding_lawnmower: bool = false

const MAX_HEALTH: int = 80
var health: int = MAX_HEALTH
# For displaying a red flash whenever the player takes damage
const DAMAGE_COOLDOWN: float = 1.25
var damage_timer: float = 0.0

# Returns a value between 0.0 and 1.0
func get_hp_perc() -> float:
	if health <= 0:
		return 0.0
	return float(health) / float(MAX_HEALTH)

func reset_health() -> void:
	health = MAX_HEALTH
	damage_timer = 0.0

# Apply damage to the player using this function
func damage(amt: int) -> void:
	health -= amt
	health = max(health, 0)
	damage_timer = DAMAGE_COOLDOWN

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

func set_animation():
	if velocity.y < 0.0:
		dir = "up"
	elif velocity.y > 0.0:
		dir = "down"
	elif velocity.x < 0.0:
		dir = "left"
	elif velocity.x > 0.0:
		dir = "right"
	
	var state = "walk"
	if velocity.length() == 0.0:
		state = "idle"
	var animation = state + "_" + dir
	$AnimatedSprite2D.animation = animation

func in_lawnmower_range():
	return $InteractZone.mower_in_range
	
# func can_pull() -> bool:
# 	return false

# 	if !mower_exists():
# 		return false
# 	if $WaterGun.visible:
# 		return false

# 	var vel = velocity.normalized()
	
# 	# Pull lawnmower with player
# 	var dot_prod = (position - lawnmower.get_sprite_pos()).normalized().dot(vel)

# 	# Compare the velocity direction with the angle to the lawnmower's position, if moving directly away from mower, it can be pulled
# 	var same_direction: bool = dot_prod > 0.7
# 	return same_direction and in_lawnmower_range()

func _process(delta: float) -> void:
	visible = health > 0
	if health <= 0:
		return
	
	set_animation()
	
	damage_timer -= delta

# func currently_pulling() -> bool:
# 	return holding_lawnmower and can_pull()

func _physics_process(_delta: float):
	if health <= 0:
		return
	
	velocity = Vector2.ZERO

	# movement
	if !$/root/Main/HUD/Control/NPCMenu.visible: #don't move when menu open
		if Input.is_action_pressed("move_up"):
			velocity.y -= 1.0
		if Input.is_action_pressed("move_down"):
			velocity.y += 1.0
		if Input.is_action_pressed("move_left"):
			velocity.x -= 1.0
		if Input.is_action_pressed("move_right"):
			velocity.x += 1.0
	
	# if currently_pulling():
	# 	speed = PULL_SPEED
	# else:
	# 	speed = SPEED
	
	# Normalize player velocity
	velocity = velocity.normalized() * SPEED

	if Input.is_action_just_pressed("interact") and in_lawnmower_range():
		mower_exists()
		holding_lawnmower = !holding_lawnmower
	elif !in_lawnmower_range():
		holding_lawnmower = false
	
	if holding_lawnmower:
		lawnmower.set_goal_position(position + (get_dir_vec() * 12.0))

	# elif velocity.length() > 0.0 and mower_exists():
	# 	var dot_prod = (position - lawnmower.get_sprite_pos()).normalized().dot(velocity.normalized())
	# 	if dot_prod < 0.0:
	# 		holding_lawnmower = false
	
	# if currently_pulling():
	# 	lawnmower.linear_velocity = velocity #TODO: Reimplement to prevent pushing the mower through walls
	# 	pulling = true
	# elif !can_pull():
	# 	if mower_exists():
	# 		lawnmower.linear_velocity = Vector2.ZERO
	# 	pulling = false
	# else:
	# 	pulling = false

	move_and_slide()

func mower_exists() -> bool:
	lawnmower = get_node_or_null(LAWNMOWER_PATH)
	return lawnmower != null and lawnmower.is_inside_tree()

func _on_interact_zone_body_entered(body: Node2D) -> void:
	if body.is_in_group("water_gun_item"):
		can_pick_up_water_gun = true

func _on_interact_zone_body_exited(body: Node2D) -> void:
	if body.is_in_group("water_gun_item"):
		can_pick_up_water_gun = false

func enable_water_gun():
	$WaterGun.show()

func disable_water_gun():
	$WaterGun.hide()

# Returns global position of the animated sprite
func get_sprite_pos():
	return $AnimatedSprite2D.position + position
