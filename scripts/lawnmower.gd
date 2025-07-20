class_name Lawnmower

extends RigidBody2D

var dir: String = "left"
var intersecting_player: bool = false
@onready var player: Player = $/root/Main/Player
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

func set_direction() -> void:
	if player.velocity.length() == 0.0:
		return

	var player_hitbox: CollisionShape2D = $/root/Main/Player/CollisionShape2D
	var player_rect: Rect2 = player_hitbox.shape.get_rect()
	player_rect.position += player.position
	var hitbox_rect: Rect2 = $CollisionShape2D.shape.get_rect()
	hitbox_rect.position += position

	var top = hitbox_rect.position.y
	var bot = hitbox_rect.position.y
	var left = hitbox_rect.position.x - hitbox_rect.size.x / (2.0 * scale.x)
	var right = hitbox_rect.position.x + hitbox_rect.size.x / (2.0 * scale.x)
	if player_rect.position.x <= left:
		dir = "right"
	elif player_rect.position.x >= right:
		dir = "left"
	elif player_rect.position.y <= top:
		dir = "down"
	elif player_rect.position.y >= bot:
		dir = "up"

	if player.velocity.x == 0.0 and player.velocity.y > 0.0:
		dir = "down"
	elif player.velocity.x == 0.0 and player.velocity.y < 0.0:
		dir = "up"
	elif player.velocity.y == 0.0 and player.velocity.x > 0.0:
		dir = "right"
	elif player.velocity.y == 0.0 and player.velocity.x < 0.0:
		dir = "left"

func set_direction_holding() -> void:
	var diff = (position - player.position).normalized()

	if abs(diff.x) < abs(diff.y):
		if diff.y > 0.0:
			dir = "down"
		else:
			dir = "up"
	else:
		if diff.x > 0.0:
			dir = "right"
		else:
			dir = "left"

func set_animation() -> void:
	if player.currently_pulling():
		set_direction_holding()
	elif intersecting_player:
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
	if player.health <= 0:
		linear_velocity = Vector2.ZERO
		return
	
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
	r.position += get_sprite_pos()
	r.size *= 1.05
	return r

# Returns global position of the shadow
func get_sprite_pos() -> Vector2:
	return position + $AnimatedSprite2D.position
