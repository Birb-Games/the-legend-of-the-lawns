extends VBoxContainer

@onready var player: Player = $/root/Main/Player

# Formats a number in seconds as a time string in the format "MM:SS"
func num_as_time_string(num: float) -> String:
	var t = floori(num)
	var minutes: int = int(floori(t / 60.0))
	var seconds: int = int(t % 60)
	return "%02d:%02d" % [minutes, seconds]

func update_status_effect(status_effect: String, time: float) -> void:
	var status_effect_timer: Node = get_node(status_effect)
	if time <= 0.0:
		status_effect_timer.hide()
		return
	status_effect_timer.show()
	var label: Label = status_effect_timer.get_node("Label")
	label.text = num_as_time_string(time)

func _process(_delta: float) -> void:
	update_status_effect("Speed", player.get_status_effect_time("speed"))
	update_status_effect("Eggplant", player.get_status_effect_time("eggplant"))
