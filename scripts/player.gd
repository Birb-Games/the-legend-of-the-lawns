class_name Player

extends CharacterBody2D

const LAWNMOWER_PATH: String = "/root/Main/Lawn/Lawnmower"
@onready var lawnmower: RigidBody2D = get_node_or_null(LAWNMOWER_PATH)
@export var water_gun: Sprite2D

const NORMAL_SPEED: float = 60.0
const PULL_SPEED: float = NORMAL_SPEED / 4.0
var speed: float = NORMAL_SPEED

var dir: String = "down"
var pulling: bool = false
var interact_text: String = ""
var can_pick_up_water_gun: bool = false

const MAX_HEALTH: int = 50
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
	if (velocity.y < 0.0 and !pulling) or (velocity.y > 0.0 and pulling):
		dir = "up"
	elif (velocity.y > 0.0 and !pulling) or (velocity.y < 0.0 and pulling):
		dir = "down"
	
	if (velocity.x < 0.0 and !pulling) or (velocity.x > 0.0 and pulling):
		dir = "left"
	elif (velocity.x > 0.0 and !pulling) or (velocity.x < 0.0 and pulling):
		dir = "right"
	
	var state = "walk"
	if velocity.length() == 0.0:
		state = "idle"
	var animation = state + "_" + dir
	$AnimatedSprite2D.animation = animation

func in_lawnmower_range():
	return $InteractZone.can_pull
	
func can_pull() -> bool:
	if !mower_exists():
		return false
	if $WaterGun.visible:
		return false

	# Pull lawnmower with player
	var dot_prod = (position - lawnmower.get_sprite_pos()).normalized().dot(velocity.normalized())
	# Compare the velocity direction with the angle to the lawnmower's position, if moving directly away from mower, it can be pulled
	var same_direction: bool = dot_prod > 0.8
	return same_direction and $InteractZone.can_pull

func _process(delta: float) -> void:
	visible = health > 0
	if health <= 0:
		return
	
	set_animation()
	
	damage_timer -= delta

func currently_pulling() -> bool:
	return Input.is_action_pressed("interact") and can_pull()

func _physics_process(_delta: float):
	if health <= 0:
		return
	
	velocity = Vector2.ZERO

	# movement
	if !$/root/Main/HUD/Control/NeighborMenu.visible: #don't move when menu open
		if Input.is_action_pressed("move_up"):
			velocity.y -= 1.0
		if Input.is_action_pressed("move_down"):
			velocity.y += 1.0
		if Input.is_action_pressed("move_left"):
			velocity.x -= 1.0
		if Input.is_action_pressed("move_right"):
			velocity.x += 1.0
	
	if currently_pulling():
		speed = PULL_SPEED
	else:
		speed = NORMAL_SPEED
	
	# Normalize player velocity
	if velocity.length() > 0.0:
		velocity /= velocity.length()
	velocity *= speed
	
	if currently_pulling():
		lawnmower.linear_velocity = velocity
		pulling = true
	elif (Input.is_action_just_released("interact") and can_pull()) or !can_pull():
		if mower_exists():
			lawnmower.linear_velocity = Vector2.ZERO
		pulling = false
	else:
		pulling = false

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
