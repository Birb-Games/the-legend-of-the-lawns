extends RigidBody2D

var dir: String = "left"
var intersecting_player: bool = false
@export var player: CharacterBody2D
var default_layer: int

func _ready() -> void:
	$Shadows/ShadowLeft.show()
	default_layer = collision_layer

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
	if intersecting_player:
		if player.velocity.x < 0.0 and !player.currently_pulling():
			dir = "left"
		elif player.velocity.x > 0.0 and !player.currently_pulling():
			dir = "right"
		
		if player.velocity.y > 0.0 and !player.currently_pulling():
			dir = "down"
		elif player.velocity.y < 0.0 and !player.currently_pulling():
			dir = "up"
	
	# Set shadows
	for shadow in $Shadows.get_children():
		shadow.hide()
	
	match dir:
		"left":
			$Shadows/ShadowLeft.show()
		"right":
			$Shadows/ShadowRight.show()
		"up":
			$Shadows/ShadowUp.show()
		"down":
			$Shadows/ShadowDown.show()
	
	$AnimatedSprite2D.animation = dir

func _process(delta: float) -> void:
	set_animation()
	# push the player back if they aren't moving
	if intersecting_player and player.velocity.length() == 0.0:
		var diff = (position - player.position).normalized()
		var dir = Vector2.ZERO
		if abs(diff.x) > abs(diff.y):
			dir = Vector2(diff.x, 0.0)
		else:
			dir = Vector2(0.0, diff.y)
		player.position -= dir * delta * 8.0

func _on_body_exited(body: Node) -> void:
	if body.is_in_group("player"):
		intersecting_player = false
		#linear_velocity = Vector2.ZERO
	if body.is_in_group("lawn_obstacle"):
		# Allow the player to pull the lawnmower again
		collision_layer = default_layer

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		intersecting_player = true
	if body.is_in_group("lawn_obstacle"):
		# Make it so that the player can not push the lawn mower any further
		# This does make it so that the lawn mower is stuck and the player has
		# to pull the lawn mower out
		collision_layer |= 1
		linear_velocity = -player.get_dir_vec()

# If the collision layer has 1 flagged, then that means that the player
# can not push the lawn mower
func is_stuck() -> bool:
	return collision_layer & 1 != 0

func rect():
	var r = $CollisionShape2D.shape.get_rect()
	r.position += position
	return r
