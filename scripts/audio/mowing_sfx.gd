extends AudioStreamPlayer

@onready var player: Player = $/root/Main/Player
@onready var default_volume: float = volume_db
var timer: float = 0.0

func _process(delta: float) -> void:
	if player.lawn_mower_active():
		timer += delta
	else:
		timer = 0.0
		stop()
	
	if timer >= 1.24 and !playing:
		play()

	var gas: float = player.get_status_effect_time("gas")
	volume_db = default_volume + lerpf(0.0, 8.0, clamp(gas / 2.0, 0.0, 1.0))
