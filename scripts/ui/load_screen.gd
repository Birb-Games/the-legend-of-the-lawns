extends Control

var entries: Array = []
var selected: int = -1

func _ready() -> void:
	$TemplateButton.hide()
	$ScrollContainer/Saves.custom_minimum_size = Vector2($ScrollContainer.size.x - 16.0, 0.0)

func clear_save_list() -> void:
	selected = -1
	for child in $ScrollContainer/Saves.get_children():
		child.queue_free()

func select(index: int) -> void:
	var main: Main = $/root/Main
	main.play_sfx("Click")
	print("Selected: ", entries[index].get_path())
	if $ScrollContainer/Saves.get_child_count() > selected + 1 and selected >= 0:	
		var button = $ScrollContainer/Saves.get_child(selected + 1)
		if button is Button:
			button.set("theme_override_colors/font_color", Color8(255, 255, 255))
			button.set("theme_override_colors/font_hover_color", Color8(255, 255, 200))
	selected = index
	if $ScrollContainer/Saves.get_child_count() > selected + 1 and selected >= 0:	
		var button = $ScrollContainer/Saves.get_child(selected + 1)
		if button is Button:
			button.set("theme_override_colors/font_color", Color8(255, 255, 0))
			button.set("theme_override_colors/font_hover_color", Color8(255, 255, 0))

func activate() -> void:
	show()
	clear_save_list()
	
	var spacing: ColorRect = ColorRect.new()
	spacing.color = Color8(0, 0, 0, 0)
	spacing.custom_minimum_size = Vector2(0.0, 8.0)
	$ScrollContainer/Saves.add_child(spacing)

	entries = Save.get_save_entries()
	var index: int = 0
	for save_entry: Save.SaveEntry in entries:
		var button: Button = $TemplateButton.duplicate()
		button.show()
		button.text = save_entry.get_display()
		button.connect(
			"pressed", 
			func() -> void:
				select(index)
		)
		$ScrollContainer/Saves.add_child(button)
		index += 1
	
	$ScrollContainer/Saves.add_child(spacing.duplicate())

func _process(_delta: float) -> void:
	$HBoxContainer/Play.disabled = selected < 0 or selected >= len(entries)
	$HBoxContainer/Delete.disabled = selected < 0 or selected >= len(entries) 

func _on_back_pressed() -> void:
	var main: Main = $/root/Main
	main.play_sfx("Click")
	clear_save_list()
	entries.clear()
	hide()

func _on_delete_pressed() -> void:
	if selected < 0 or selected >= entries.size():
		return
	var main: Main = $/root/Main
	main.play_sfx("Click")
	$ScrollContainer.hide()
	$HBoxContainer.hide()
	$Back.hide()
	$Confirm.show()
	$Confirm/Message.text = "Are you sure you want to delete this save?\n\n"
	$Confirm/Message.text += entries[selected].get_display()
	$Confirm/Message.text += "\n\nTHIS IS PERMANENT!"

func _on_no_pressed() -> void:
	var main: Main = $/root/Main
	main.play_sfx("Click")
	$Confirm.hide()
	$ScrollContainer.show()
	$HBoxContainer.show()
	$Back.show()

func _on_yes_pressed() -> void:	
	$Confirm.hide()
	$ScrollContainer.show()
	$HBoxContainer.show()
	$Back.show()
	
	if selected < 0 or selected >= entries.size():
		return
	var main: Main = $/root/Main
	main.play_sfx("Click")
	var path: String = entries[selected].get_path()

	if path.is_empty():
		activate()
		return

	DirAccess.remove_absolute(path)	
	if main.continue_save == path:
		main.save_path = ""
		main.update_continue_save()

	activate()

func _on_play_pressed() -> void:
	if selected < 0 or selected >= entries.size():
		return

	var main: Main = $/root/Main
	main.play_sfx("Click")
	
	hide()
	var main_menu = get_parent()
	main_menu.hide()
	var selected_index: int = selected
	clear_save_list()

	get_tree().paused = false
	main.save_path = entries[selected_index].get_path()
	main.reset()
	if !main.load_save():
		get_tree().paused = true
		main_menu.show()
		return
	$/root/Main/HUD/Control/TransitionRect.start_animation()
