extends Area2D

var player_in_area: bool = false

@export var interact_text: String = "Door"
@export var go_to: Node2D

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("interact") and player_in_area and go_to:
		var player: Player = $/root/Main/Player
		player.position = go_to.position
		player.dir = "down"
		# Activate transition animation
		$/root/Main/HUD/Control/TransitionRect.start_bus_animation()
		$/root/Main/Player/Camera2D.position_smoothing_enabled = false

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		body.interact_text = "%s - [SPACE]" % interact_text
		player_in_area = true

func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		body.interact_text = ""
		player_in_area = false
