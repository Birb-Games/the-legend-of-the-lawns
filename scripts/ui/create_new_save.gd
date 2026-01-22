extends Control

@export var intro: PackedScene

func activate() -> void:
	show()
	$Name/Error.text = ""
	$Name/TextEdit.text = ""

func _on_back_pressed() -> void:
	var main: Main = $/root/Main	
	main.play_sfx("Click")
	hide()

func _on_start_pressed() -> void:	
	# Make sure we have a valid name
	var player_name: String = $Name/TextEdit.text
	if player_name.is_empty():
		player_name = $Name/TextEdit.placeholder_text

	# Make sure the string isn't only whitespace
	if player_name.strip_edges().is_empty():
		printerr("Invalid name: name consists of only whitespace.")
		$Name/Error.text = "Invalid name."
		$ErrorSound.play()
		return

	var main: Main = $/root/Main	
	main.play_sfx("Click")
	get_tree().paused = false
	hide()
	var main_menu = get_parent()
	main_menu.hide()

	main.player_name = player_name
	main.reset()
	# Kind of meant to be a joke/easter egg but also helpful for testing
	var lowercase: String = player_name.to_lower()
	if lowercase == "elon musk" or lowercase == "jeff bezos" or lowercase == "bill gates":
		main.money = 9999999999
	
	# $/root/Main/HUD/Control/TransitionRect.start_animation()
	$/root/Main/HUD/Control.add_child(intro.instantiate())
	get_tree().paused = true
	$/root/Main/HUD/Control/QuestScreen.show_alert = true
	
	print("Created new save: \"%s\"" % player_name)
	var id: int = 0
	while FileAccess.file_exists(Save.get_save_path(player_name, id)):
		id += 1
	var save_path: String = Save.get_save_path(player_name, id)
	print("Saving to: ", save_path)
	main.save_path = save_path
	main.save_progress()

	main.player.global_position = $/root/Main/Neighborhood/Intro/PlayerStart.global_position

	main.update_continue_save()

