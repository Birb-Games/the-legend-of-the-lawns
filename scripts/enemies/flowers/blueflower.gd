extends FlowerEnemy

@export var thorn_bullet: PackedScene
@export var spore_bullet: PackedScene

func _ready() -> void:
	# Set bullet_scene to be spore_bullet so that when the enemy dies they
	# explode into a collection of spore bullets
	bullet_scene = spore_bullet

func rand_bullet() -> PackedScene:
	if randi() % 3 == 0:
		return spore_bullet
	return thorn_bullet

func shoot() -> void:
	var offset = randf() * 2.0 * PI
	# Shoot 6 bullets at once
	for i in range(0, 6):
		var bullet = rand_bullet()
		shoot_bullet(bullet, offset + i * 2.0 * PI / 6.0)
