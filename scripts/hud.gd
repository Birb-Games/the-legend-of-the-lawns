extends CanvasLayer

func _ready() -> void:
	$Control/InfoText.text = ""

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
