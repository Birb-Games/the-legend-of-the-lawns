extends CharacterBody2D

@export var lawn_mower: RigidBody2D

var speed: int = 80
var push_force = 500

var collided: bool = false
var collision: KinematicCollision2D

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

	collided = move_and_slide()

	# Push Mower
	# https://forum.godotengine.org/t/how-to-push-a-rigidbody2d-with-a-characterbody2d/2681/2
	if collided:
		for i in get_slide_collision_count():
			collision = get_slide_collision(i)
			if collision.get_collider() == lawn_mower:
				lawn_mower.apply_force(collision.get_normal() * -push_force)

	if !collided:
		lawn_mower.linear_velocity *= .7
