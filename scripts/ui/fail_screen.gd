extends Control

@export var knocked_out: PackedScene
var knocked_out_sprite: Node2D
var time_active: float = 0.0

func _ready() -> void:
	hide()

func _process(delta: float) -> void:
	if !visible:
		return
	if time_active < 0.5 and time_active + delta >= 0.5:
		$GameOver.play()
	time_active += delta

func activate() -> void:
	$/root/Main.play_sfx("Hurt", true)
	time_active = 0.0
	# Add knocked out player
	knocked_out_sprite = knocked_out.instantiate()
	knocked_out_sprite.position = $/root/Main/Player.position
	$/root/Main.add_child(knocked_out_sprite)
	show()
	$/root/Main.current_wage = 0

func _on_return_pressed() -> void:
	if knocked_out_sprite != null:
		knocked_out_sprite.queue_free()
		knocked_out_sprite = null
	get_tree().paused = false
	var main: Main = $/root/Main
	main.play_sfx("Click")
	main.advance_day()
	main.return_to_neighborhood()
	main.save_progress()
	hide()
