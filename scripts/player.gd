extends CharacterBody2D

@export var lawnmower: RigidBody2D

var speed: int = 80

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
	
	# Pull lawnmower with player
	var comparison_vector: Vector2 = abs(velocity.normalized() + Vector2.from_angle(get_angle_to(lawnmower.position)))
	var same_direction: bool = comparison_vector.x <= 0.1 or comparison_vector.y <= 0.1
		# Compare the velocity direction with the angle to the lawnmower's position, if moving directly away from mower, it can be pulled
		
	if Input.is_action_pressed("pull") and $Pull.can_pull and same_direction:
		lawnmower.linear_velocity = velocity
	elif (Input.is_action_just_released("pull") and $Pull.can_pull) or !same_direction:
		lawnmower.linear_velocity = Vector2.ZERO

	move_and_slide()
