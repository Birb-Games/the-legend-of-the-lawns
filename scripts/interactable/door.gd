extends Area2D

var player_in_area: bool = false

@export var interact_text: String = "Door"
@export_multiline var unavailable_msg: String = ""
@export var go_to: Node2D
# Set this to -1 if you want the door to always be accessible
@export var min_level: int = -1
@export var quest_door: bool = false

func _process(_delta: float) -> void:
	var main: Main = $/root/Main
	var current_quest: Quest = Quest.get_quest(main.current_level)
	if main.current_level < min_level:
		if (current_quest == null or !current_quest.completed(main)) and quest_door:
			return
	if Input.is_action_just_pressed("interact") and player_in_area and go_to:
		$/root/Main.play_sfx("Door")
		if quest_door:
			main.advance_quest()
			$/root/Main/HUD/Control/QuestScreen.show_alert = true
		var player: Player = $/root/Main/Player
		player.position = go_to.position
		player.dir = "down"
		# Activate transition animation
		$/root/Main/HUD/Control/TransitionRect.start_bus_animation()
		$/root/Main/Player/Camera2D.position_smoothing_enabled = false

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		var main: Main = $/root/Main
		var current_quest: Quest = Quest.get_quest(main.current_level)
		if main.current_level >= min_level or (current_quest and current_quest.completed(main)):
			body.interact_text = "%s - [SPACE]" % interact_text
		else:
			body.interact_text = unavailable_msg
		player_in_area = true

func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		body.interact_text = ""
		player_in_area = false
