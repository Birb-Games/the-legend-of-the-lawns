extends PlayerBullet

class_name FireBullet

func explode() -> void:
	super.explode()
	# Spawn a fire
	var fire: Fire = Fire.fire_scene.instantiate()
	fire.global_position = global_position
	var lawn: Lawn = get_node_or_null("/root/Main/Lawn")
	if lawn:
		lawn.call_deferred("add_child", fire)

func _process(delta: float) -> void:
	super._process(delta)
	# Prevent the fire particles from rotating	
	$FireParticles.rotation = -rotation
