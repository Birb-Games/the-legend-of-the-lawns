extends Area2D

@onready var default_scale: Vector2 = scale
@export var shock_particles_scene: PackedScene

func _ready() -> void:
	scale = Vector2(0.0, 0.0)

func _process(delta: float) -> void:
	# Expand
	scale.x += delta * 3.0
	scale.y = scale.x

	$Sprite2D.rotation += delta * PI * 2.0
	$Sprite2D2.rotation -= delta * PI * 3.0

	# Fade out the electric shock
	if scale.x > default_scale.x:
		modulate.a -= delta * 4.0
	
	if modulate.a < 0.0:
		queue_free()

func add_shock_particles(parent: Node) -> void:
	if parent == null:
		return
	var shock_particles: GPUParticles2D = shock_particles_scene.instantiate()
	shock_particles.position = Vector2.ZERO
	parent.add_child(shock_particles)

func _on_area_entered(area: Area2D) -> void:
	if modulate.a < 0.2:
		return	
	if area is WeedEnemy:
		$/root/Main.play_sfx("Zap")
		area.health -= randi_range(3, 8)
		add_shock_particles(area)
		if !area.visible or !area.is_inside_tree():
			return
	elif area is FlowerEnemy:
		area.health -= randi_range(2, 4)
		area.stun()
		add_shock_particles(area)
		if !area.visible or !area.is_inside_tree():
			return
	elif area is Worm:
		$/root/Main.play_sfx("Zap")
		area.damage(randi_range(3, 8))
		add_shock_particles(area)
		if !area.visible or !area.is_inside_tree():
			return
