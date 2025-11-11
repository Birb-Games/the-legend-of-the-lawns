extends Area2D

var player_in_area: bool = false

func _process(_delta: float) -> void:
	if player_in_area and Input.is_action_just_pressed("interact"):
		$/root/Main/HUD.set_skip_day_menu()

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		player_in_area = true	
		body.interact_text = "[SPACE]"

func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		player_in_area = false
		body.interact_text = ""
