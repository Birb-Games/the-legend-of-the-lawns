extends RigidBody2D

var dir: String = "left"
var intersecting_player: bool = false
@onready var player: CharacterBody2D = $/root/Main/Player
var default_layer: int
var stuck_in_wall = false
var can_push = true

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

func set_direction():
	if player.velocity.x < 0.0 and !player.currently_pulling():
		dir = "left"
	elif player.velocity.x > 0.0 and !player.currently_pulling():
		dir = "right"
		
	if player.velocity.y > 0.0 and !player.currently_pulling():
		dir = "down"
	elif player.velocity.y < 0.0 and !player.currently_pulling():
		dir = "up"
	
	if player.velocity.x == 0.0 or player.velocity.y == 0.0:
		return
	
	var diff = (player.position + Vector2(0.0, 8.0) - position).normalized()
	if abs(diff.x) > abs(diff.y) * sqrt(3.0) / 2.0:
		if player.velocity.x < 0.0 and !player.currently_pulling():
			dir = "left"
		elif player.velocity.x > 0.0 and !player.currently_pulling():
			dir = "right"
	else:
		if player.velocity.y > 0.0 and !player.currently_pulling():
			dir = "down"
		elif player.velocity.y < 0.0 and !player.currently_pulling():
			dir = "up"

func set_animation():
	if intersecting_player:
		set_direction()
	
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
	if stuck_in_wall or can_push:
		collision_layer |= 1
	else:
		collision_layer = default_layer
	
	set_animation()
	# push the player back if they aren't moving
	if intersecting_player and player.velocity.length() == 0.0:
		var diff = (position - player.position).normalized()
		player.position -= diff * delta * 8.0

func _on_body_exited(body: Node) -> void:
	if body.is_in_group("player"):
		intersecting_player = false
	if body.is_in_group("lawn_obstacle"):
		# Allow the player to pull the lawnmower again
		stuck_in_wall = false

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		intersecting_player = true
	if body.is_in_group("lawn_obstacle"):
		# Make it so that the player can not push the lawn mower any further
		# This does make it so that the lawn mower is stuck and the player has
		# to pull the lawn mower out
		stuck_in_wall = true

# If the collision layer has 1 flagged, then that means that the player
# can not push the lawn mower
func is_stuck() -> bool:
	return collision_layer & 1 != 0

func rect():
	var r = $CollisionShape2D.shape.get_rect()
	r.position += position
	return r

# Returns global position of the shadow
func get_sprite_pos() -> Vector2:
	return position + $AnimatedSprite2D.position
