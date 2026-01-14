extends Mushroom

@export var fungal_baby_scene: PackedScene
const MIN_SPAWN_TIME: float = 4.0
const MAX_SPAWN_TIME: float = 8.0
@onready var spawn_timer: float = 2.0
# In tile units
const MIN_SPAWN_DIST: float = 2.0
const MAX_SPAWN_DIST: float = 4.0

func shoot() -> void:
	# Shoot 2 - 4 bullets
	var bullet_count: int = randi_range(2, 4)
	for i in range(0, bullet_count):
		var offset = PI / 6.0 * (float(i) - float(bullet_count - 1) / 2.0)
		shoot_bullet(offset)

func _on_hit() -> void:
	call_deferred("shoot")

# Spawns 1 - 3 fungal babies
func spawn_babies(lower: int, upper: int) -> void:
	if !player_in_range():
		return
	if player.health <= 0:
		return

	var count: int = randi_range(lower, upper)
	var lawn: Lawn = get_node_or_null("/root/Main/Lawn")
	if lawn == null:
		return

	for i in range(count):
		Spawning.spawn_around_point(
			lawn,
			lawn.get_node("MobileEnemies"),
			global_position,
			fungal_baby_scene,
			MIN_SPAWN_DIST, 
			MAX_SPAWN_DIST,
		)

func explode() -> void:
	super.explode()
	# Spawn babies upon death
	spawn_babies(2, 4)

func _process(delta: float) -> void:
	super._process(delta)

	spawn_timer -= delta
	if spawn_timer > 0.0:
		return
	spawn_timer = randf_range(MIN_SPAWN_TIME, MAX_SPAWN_TIME)
	spawn_babies(1, 3)
