extends RigidBody2D

var dir: String = "left"
var intersecting_player: bool = false
@export var player: CharacterBody2D

func _ready() -> void:
	$Shadows/ShadowLeft.show()

func set_animation():
	var prev_dir = dir
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
		player.position -= player.get_dir_vec() * delta * 8.0

func _on_body_exited(body: Node) -> void:
	if body.is_in_group("player"):
		intersecting_player = false
		linear_velocity = Vector2.ZERO

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		intersecting_player = true
