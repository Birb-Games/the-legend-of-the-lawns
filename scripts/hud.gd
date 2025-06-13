extends CanvasLayer

func _ready() -> void:
	$Control/InfoText.text = ""

	$Control/NeighborMenu/VBoxContainer/HBoxContainer/Leave.pressed.connect($/root/Main._on_leave_button_pressed)
	$Control/NeighborMenu/VBoxContainer/HBoxContainer/Accept.pressed.connect($/root/Main._on_accept_button_pressed)

# used for pop up messages to provide information to the player
func update_info_text(text: String) -> void:
	$Control/InfoText.text = text

# updates progress bar based on the given percent (0.0 to 1.0)
func update_progress_bar(percent: float) -> void:
	if percent < 0.0: #used for the neighborhood
		$Control/ProgressBar.hide()
		$Control/ProgressBackground.hide()
		$Control/ProgressBarPercent.hide()
		return
	else:
		$Control/ProgressBar.show()
		$Control/ProgressBackground.show()
		$Control/ProgressBarPercent.show()
		$Control/ProgressBar.size.x = percent * $Control/ProgressBackground.size.x
		$Control/ProgressBarPercent.text = str(int(percent * 100)) + "%"

func set_neighbor_menu(neighbor_name: String, wage: float, description: String) -> void:
	$Control/NeighborMenu/VBoxContainer/Name.text = neighbor_name
	$Control/NeighborMenu/VBoxContainer/Wage.text = "$" + str(wage)
	$Control/NeighborMenu/VBoxContainer/Description.text = description
	$Control/NeighborMenu/VBoxContainer/HBoxContainer/Accept.disabled = false
	$Control/NeighborMenu/VBoxContainer/HBoxContainer/Leave.disabled = false
	$Control/NeighborMenu.visible = true

func hide_neighbor_menu() -> void:
	$Control/NeighborMenu.visible = false
	$Control/NeighborMenu/VBoxContainer/HBoxContainer/Accept.disabled = true
	$Control/NeighborMenu/VBoxContainer/HBoxContainer/Leave.disabled = true
