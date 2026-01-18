extends Area2D

class_name BusStop

var player_in_area: bool = false

@export var display_name: String
@export var connections: Array[BusStop]

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("interact") and player_in_area:
		$/root/Main.play_sfx("Click")
		$/root/Main/HUD.set_bus_menu(self)

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		body.interact_text = "Bus stop - [SPACE]"
		player_in_area = true

func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		body.interact_text = ""
		player_in_area = false

