extends CharacterBody2D

var speed: int = 10000

func _physics_process(delta: float):
	velocity = Vector2.ZERO
	if Input.is_action_pressed("move_up"):
		velocity.y -= speed * delta
	if Input.is_action_pressed("move_down"):
		velocity.y += speed * delta
	if Input.is_action_pressed("move_left"):
		velocity.x -= speed * delta
	if Input.is_action_pressed("move_right"):
		velocity.x += speed * delta

	move_and_slide()
