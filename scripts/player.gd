extends CharacterBody2D

@export var lawnmower: RigidBody2D
@export var water_gun: Sprite2D

const NORMAL_SPEED: float = 60.0
const PULL_SPEED: float = NORMAL_SPEED / 4.0
var speed: float = NORMAL_SPEED

var dir: String = "down"
var pulling: bool = false

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
	if (velocity.x < 0.0 and !pulling) or (velocity.x > 0.0 and pulling):
		dir = "left"
	elif (velocity.x > 0.0 and !pulling) or (velocity.x < 0.0 and pulling):
		dir = "right"
	
	if (velocity.y < 0.0 and !pulling) or (velocity.y > 0.0 and pulling):
		dir = "up"
	elif (velocity.y > 0.0 and !pulling) or (velocity.y < 0.0 and pulling):
		dir = "down"
	
	var state = "walk"
	if velocity.length() == 0.0:
		state = "idle"
	var animation = state + "_" + dir
	$AnimatedSprite2D.animation = animation
	
func can_pull() -> bool:
	if !mower_exists():
		return false

	# Pull lawnmower with player
	var dot_prod = (position - lawnmower.position).normalized().dot(velocity.normalized())
	# Compare the velocity direction with the angle to the lawnmower's position, if moving directly away from mower, it can be pulled
	var same_direction: bool = dot_prod > 0.8
	return same_direction and $Pull.can_pull

func _process(_delta: float) -> void:
	set_animation()

func currently_pulling() -> bool:
	return Input.is_action_pressed("pull") and can_pull()

func _physics_process(_delta: float):
	velocity = Vector2.ZERO

	#movement
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
	elif (Input.is_action_just_released("pull") and can_pull()) or !can_pull():
		if mower_exists():
			lawnmower.linear_velocity = Vector2.ZERO
		pulling = false
	else:
		pulling = false

	move_and_slide()

func mower_exists() -> bool:
	lawnmower = get_node_or_null("/root/Main/Lawnmower")
	return lawnmower != null and lawnmower.is_inside_tree()
