extends Control

var time: float = 0.0
const FADE_TIME: float = 2.0

func _ready() -> void:
	var viewport: Rect2 = get_viewport_rect()
	$Sprite2D.position = viewport.size / 2.0

func _process(delta: float) -> void:
	time += delta
	time = clamp(time, 0.0, FADE_TIME)
	var value: int = int(255.0 * pow(time / FADE_TIME, 2))
	$Sprite2D.modulate = Color8(value, value, value)

func _on_button_pressed() -> void:
	$/root/Main/HUD/Control/TransitionRect.start_animation()
	$/root/Main.play_sfx("Click")
	get_tree().paused = false
	queue_free()

