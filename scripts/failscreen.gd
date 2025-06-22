extends Control

@export var knocked_out: PackedScene
var knocked_out_sprite

func _ready() -> void:
	hide()

func activate() -> void:
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
	var main = $/root/Main
	main.current_day += 1
	main.return_to_neighborhood()
	hide()
