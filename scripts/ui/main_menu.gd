extends Control

const SUBTITLE_SCALE_RATE: float = 0.15
var subtitle_font_scale_change: float = SUBTITLE_SCALE_RATE

const SUBTITLE_MIN_SCALE: float = 0.9
const SUBTITLE_MAX_SCALE: float = 1.05

func _ready() -> void:
	show()
	if OS.get_name() == "Web":
		$Buttons/Quit.hide()
	
	# TODO: implement a save system
	$Buttons/Continue.disabled = true
	$Buttons/Load.disabled = true

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

func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_credits_pressed() -> void:
	$Credits.show()

func _on_new_game_pressed() -> void:
	get_tree().paused = false
	$/root/Main/HUD/Control/TransitionRect.start_animation()
	hide()
