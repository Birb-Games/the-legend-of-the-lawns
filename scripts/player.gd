extends CharacterBody2D

var speed: int = 80

func _physics_process(delta: float):
	velocity = Vector2.ZERO
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

	move_and_slide()
