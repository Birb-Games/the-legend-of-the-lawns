extends WeedEnemy

func _ready() -> void:
	super._ready()
	shoot_timer = 1.0

func shoot() -> void:
	# Some inaccuracy
	var rand_angle = randf() * PI / 3.0 - PI / 6.0
	shoot_bullet(rand_angle)
