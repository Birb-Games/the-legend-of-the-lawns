extends StaticBody2D

class_name TrashCan

var player_in_area: bool = false

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("interact") and player_in_area and !$/root/Main/HUD.npc_menu_open():
		$/root/Main.play_sfx("Click")
		$/root/Main/HUD/Control/NPCMenu.set_trash_menu()

func _on_area_2d_body_entered(body: Node2D) -> void:	
	if body is Player:
		body.interact_text = "Trash - [SPACE]"
		player_in_area = true

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body is Player:
		body.interact_text = ""
		player_in_area = false
