extends Control

func activate() -> void:
	show()
	$Name/Error.text = ""

func _on_back_pressed() -> void:
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
		return

	get_tree().paused = false
	hide()
	var main_menu = get_parent()
	main_menu.hide()

	var main: Main = $/root/Main
	main.player_name = player_name
	main.reset()
	# Kind of meant to be a joke/easter egg but also helpful for testing
	var lowercase: String = player_name.to_lower()
	if lowercase == "elon musk" or lowercase == "jeff bezos" or lowercase == "bill gates":
		main.money = 9999999999
		main.lawns_mowed = 999
	
	$/root/Main/HUD/Control/TransitionRect.start_animation()
	
	print("Created new save: \"%s\"" % player_name)
	var id: int = 0
	while FileAccess.file_exists(Save.get_save_path(player_name, id)):
		id += 1
	var save_path: String = Save.get_save_path(player_name, id)
	print("Saving to: ", save_path)
	main.save_path = save_path
	main.save_progress()

	main.update_continue_save()

