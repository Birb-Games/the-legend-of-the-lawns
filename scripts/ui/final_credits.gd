extends Control

var slides: Array
@export var slide_json: JSON
var slide_text: Array

var current_slide: int = 0
@onready var credits_y: float = $Credits.position.y
const SPEED: float = 24.0

func _ready() -> void:
	$HBoxContainer.hide()
	slide_text = Save.get_val(slide_json.data, "slide_text", [])
	slides = Save.get_val(slide_json.data, "slides", [])

	var scene
	for path: String in slides:
		scene = get_node_or_null(path)
		if scene:
			scene.hide()
	
	scene = get_node_or_null(slides[current_slide])
	if scene:
		scene.show()
	$Label.text = ""
	if current_slide < slide_text.size():
		$Label.text = slide_text[current_slide]
	else:
		$Label.text = ""

func _process(delta: float) -> void:
	# Slide the credits across the screen
	if current_slide >= slides.size():
		var speed: float = SPEED
		if Input.is_action_pressed("interact"):
			speed *= 4.0
		$Title.position.y -= delta * speed
		credits_y -= delta * speed
		$Credits.position.y = floori(credits_y)

func _on_next_pressed() -> void:
	if current_slide >= slides.size():
		return
	var scene = get_node_or_null(slides[current_slide])
	if scene:
		scene.hide()
	current_slide += 1
	$Click.play()
	if current_slide >= slides.size():
		$HBoxContainer.show()
		$Label.hide()
		$Next.hide()
		return
	scene = get_node_or_null(slides[current_slide])
	if scene:
		scene.show()
	$Label.text = ""
	if current_slide < slide_text.size():
		$Label.text = slide_text[current_slide]
	else:
		$Label.text = ""

func _on_return_pressed() -> void:
	var main: Main = get_node_or_null("/root/Main")
	if main:
		main.return_to_neighborhood()
		$/root/Main/HUD/Control/TransitionRect.start_animation()
		main.play_sfx("Door")
	get_tree().paused = false
	queue_free()
