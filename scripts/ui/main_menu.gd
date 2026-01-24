extends Control

const SUBTITLE_SCALE_RATE: float = 0.15
var subtitle_font_scale_change: float = SUBTITLE_SCALE_RATE

const SUBTITLE_MIN_SCALE: float = 0.9
const SUBTITLE_MAX_SCALE: float = 1.05

func _ready() -> void:
	show()
	if OS.get_name() == "Web":
		$Buttons/Quit.hide()	

func _process(delta: float) -> void:
	if !visible:
		return
	$Title/SubtitleParent.scale.x += subtitle_font_scale_change * delta
	$Title/SubtitleParent.scale.y = $Title/SubtitleParent.scale.x
	if $Title/SubtitleParent.scale.x > SUBTITLE_MAX_SCALE:
		subtitle_font_scale_change = -SUBTITLE_SCALE_RATE
	elif $Title/SubtitleParent.scale.x < SUBTITLE_MIN_SCALE:
		subtitle_font_scale_change = SUBTITLE_SCALE_RATE
	$Title/SubtitleParent.scale.x = clamp($Title/SubtitleParent.scale.x, SUBTITLE_MIN_SCALE, SUBTITLE_MAX_SCALE)
	$Title/SubtitleParent.scale.y = $Title/SubtitleParent.scale.x

	var main: Main = $/root/Main
	$Buttons/Continue.disabled = main.continue_save.is_empty()

func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_credits_pressed() -> void:
	var main: Main = $/root/Main
	main.play_sfx("Click")
	$Credits.show()

func _on_new_game_pressed() -> void:
	var main: Main = $/root/Main
	main.play_sfx("Click")
	$CreateNewSave.activate()

func _on_load_pressed() -> void:
	var main: Main = $/root/Main
	main.play_sfx("Click")
	$LoadScreen.activate()

func _on_continue_pressed() -> void:
	var main: Main = $/root/Main	
	main.play_sfx("Click")
	main.save_path = main.continue_save
	main.reset()
	if !main.load_save():
		main.save_path = ""
		main.update_continue_save()
		return
	hide()
	get_tree().paused = false
	$/root/Main/HUD/Control/TransitionRect.start_animation()

func _on_settings_pressed() -> void:
	var main: Main = $/root/Main
	main.play_sfx("Click")
	$SettingsScreen.activate()
