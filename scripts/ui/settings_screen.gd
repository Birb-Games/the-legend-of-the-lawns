extends Control

var in_game: bool = false

func set_slider_val(slider_name: String, value: float) -> void:
	var slider: Slider = get_node("ScrollContainer/VBoxContainer/%s/Slider" % slider_name)
	slider.value = value

func set_slider_label(slider_name: String, msg: String) -> void:
	var label: Label = get_node("ScrollContainer/VBoxContainer/%s/Label" % slider_name)
	label.text = msg

func get_slider_val(slider_name: String) -> float:
	var slider: Slider = get_node("ScrollContainer/VBoxContainer/%s/Slider" % slider_name)
	return slider.value

func activate() -> void:
	show()

	# Load settings
	Settings.load()	
	set_menu_values()

func set_menu_values() -> void:
	set_slider_val("MasterVolume", Settings.master_volume * 100.0)
	set_slider_val("LawnMowerVolume", Settings.lawn_mower_volume * 100.0)
	set_slider_val("UIVolume", Settings.ui_volume * 100.0)

func update_settings() -> void:
	Settings.master_volume = get_slider_val("MasterVolume") / 100.0
	Settings.lawn_mower_volume = get_slider_val("LawnMowerVolume") / 100.0
	Settings.ui_volume = get_slider_val("UIVolume") / 100.0

func _on_back_pressed() -> void:
	var main: Main = $/root/Main
	main.play_sfx("Click")
	update_settings()
	Settings.save()
	Settings.apply_settings()
	hide()
	if in_game:
		# Hide main menu (the parent of this node) if we're in game
		get_parent().hide()
	in_game = false

func _on_reset_pressed() -> void:
	var main: Main = $/root/Main
	main.play_sfx("Click")
	Settings.reset()
	Settings.save()
	Settings.apply_settings()
	set_menu_values()

func _on_undo_pressed() -> void:	
	var main: Main = $/root/Main
	main.play_sfx("Click")
	set_menu_values()

func _process(_delta: float) -> void:
	if !visible:
		return

	var master_vol_perc: float = int(round(get_slider_val("MasterVolume")))
	set_slider_label("MasterVolume", " Master Volume (%d%%)" % master_vol_perc)
	var lawn_mower_vol_perc: float = int(round(get_slider_val("LawnMowerVolume")))
	set_slider_label("LawnMowerVolume", " Lawn Mower Volume (%d%%)" % lawn_mower_vol_perc)
	var ui_vol_perc: float = int(round(get_slider_val("UIVolume")))
	set_slider_label("UIVolume", " UI Volume (%d%%)" % ui_vol_perc)

