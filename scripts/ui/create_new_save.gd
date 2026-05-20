extends Control

@export var intro: PackedScene

const REPLACE_WITH_UNDERSCORE: Array = [ '/', '\\', '<', '>', ':', '"', '|', '?', '*', ' ', '.' ]

func activate() -> void:
	show()
	$Name/Error.text = ""
	$Name/LineEdit.text = ""

func _on_back_pressed() -> void:
	var main: Main = $/root/Main	
	main.play_sfx("Click")
	hide()

# Convert all illegal characters in the string into underscores
static func convert_name_to_save(player_name: String) -> String:
	var modified_name: String = ""
	for i in range(player_name.length()):
		var ch: String = char(player_name.unicode_at(i))
		# Strip out unprintable characters
		if ord(ch) <= 31:
			continue
		if ch in REPLACE_WITH_UNDERSCORE:
			ch = '_'
		modified_name += ch
	return modified_name

func _on_start_pressed() -> void:	
	$/root/Main/HUD.reset()
	# Make sure we have a valid name
	var player_name: String = $Name/LineEdit.text
	if player_name.is_empty():
		player_name = $Name/LineEdit.placeholder_text
	player_name = player_name.strip_edges()

	# Make sure the string isn't only whitespace
	if player_name.is_empty():
		printerr("Invalid name: name consists of only whitespace.")
		$Name/Error.text = "Invalid name."
		$ErrorSound.play()
		return

	if player_name.length() > 80:
		printerr("Invalid name: name is too long.")
		$Name/Error.text = "Name is too long.\nMax length is 80 chars."
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
	if lowercase == "mcmoneypants":
		main.money = 9999999999
	
	# $/root/Main/HUD/Control/TransitionRect.start_animation()
	$/root/Main/HUD/Control.add_child(intro.instantiate())
	get_tree().paused = true
	$/root/Main/HUD/Control/QuestScreen.show_alert = true
	
	var save_name: String = convert_name_to_save(player_name)
	print("Created new save: \"%s\"" % save_name)
	var id: int = 0
	while FileAccess.file_exists(Save.get_save_path(save_name, id)):
		id += 1
	var save_path: String = Save.get_save_path(save_name, id)
	print("Saving to: ", save_path)
	main.save_path = save_path
	main.save_progress()

	main.player.global_position = $/root/Main/Neighborhood/Intro/PlayerStart.global_position

	main.update_continue_save()

