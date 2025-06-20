extends Area2D

@onready var player = $/root/Main/Player

func get_dir() -> String:
	var diff = player.get_sprite_pos() - global_position
	var norm = diff.normalized()
	
	if abs(norm.x) > abs(norm.y):
		if norm.x < 0.0:
			return "left"
		else:
			return "right"
	else:
		if norm.y < 0.0:
			return "up"
		else:
			return "down"

func _process(_delta: float) -> void:
	$AnimatedSprite2D.animation = get_dir()
