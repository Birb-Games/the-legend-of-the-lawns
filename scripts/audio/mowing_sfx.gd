extends AudioStreamPlayer

@onready var player: Player = $/root/Main/Player
var timer: float = 0.0

func _process(delta: float) -> void:
	if player.lawn_mower_active():
		timer += delta
	else:
		timer = 0.0
		stop()
	
	if timer >= 1.24 and !playing:
		play()
