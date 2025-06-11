extends CharacterBody2D

@export var lawnmower: RigidBody2D

var speed: int = 60

var dir: String = "down"

func set_animation():
	if velocity.x < 0.0:
		dir = "left"
	elif velocity.x > 0.0:
		dir = "right"
	
	if velocity.y < 0.0:
		dir = "up"
	elif velocity.y > 0.0:
		dir = "down"
	
	var state = "walk"
	if velocity.length() == 0.0:
		state = "idle"
	var animation = state + "_" + dir
	$AnimatedSprite2D.animation = animation
	
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
	
	# Pull lawnmower with player
	if Input.is_action_pressed("pull") and $Pull.can_pull:
		lawnmower.linear_velocity = velocity
	elif Input.is_action_just_released("pull") and $Pull.can_pull:
		lawnmower.linear_velocity = Vector2.ZERO

	move_and_slide()
