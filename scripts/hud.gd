extends CanvasLayer

func _ready() -> void:
	$Control/InfoText.text = ""

# used for pop up messages to provide information to the player
func update_info_text(text: String) -> void:
	$Control/InfoText.text = text
