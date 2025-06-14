extends CanvasLayer

func _ready() -> void:
	$Control/InfoText.text = ""

# used for pop up messages to provide information to the player
func update_info_text(text: String) -> void:
	$Control/InfoText.text = text

# updates progress bar based on the given percent (0.0 to 1.0)
func update_progress_bar(percent: float) -> void:
	# used for the neighborhood
	if percent < 0.0:
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

func set_neighbor_menu(neighbor: AnimatedSprite2D) -> void:
	$Control/NeighborMenu.set_menu(neighbor)

func hide_neighbor_menu() -> void:
	$Control/NeighborMenu.hide_menu()
