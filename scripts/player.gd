extends CharacterBody2D

@export var lawnmower: RigidBody2D
@export var water_gun: Sprite2D

var speed: int = 60

var dir: String = "down"
var pulling: bool = false

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
	# Pull lawnmower with player
	var dot_prod = (position - lawnmower.position).normalized().dot(velocity.normalized())
	# Compare the velocity direction with the angle to the lawnmower's position, if moving directly away from mower, it can be pulled
	var same_direction: bool = dot_prod > 0.8
	return same_direction and $Pull.can_pull

func _process(delta: float) -> void:
	set_animation()

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
	
	# Normalize player velocity
	if velocity.length() > 0.0:
		velocity /= velocity.length()
	velocity *= speed
	
	if Input.is_action_pressed("pull") and can_pull():
		lawnmower.linear_velocity = velocity
		pulling = true
	elif (Input.is_action_just_released("pull") and can_pull()) or !can_pull():
		lawnmower.linear_velocity = Vector2.ZERO
		pulling = false
	else:
		pulling = false

	move_and_slide()
