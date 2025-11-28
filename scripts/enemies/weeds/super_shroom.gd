extends Mushroom

const POSSIBLE_SHOOT_MODES: Array[String] = [
	"circle",
	"target",
	"rapid_fire",
	"triple_spiral",
]
var shoot_mode: String = "circle"
const UPDATE_SHOOT_MODE_INTERVAL: float = 6.0
var update_shoot_mode_timer: float = UPDATE_SHOOT_MODE_INTERVAL
@onready var bullet_queue: BulletQueue = BulletQueue.new()

func get_random_shoot_mode() -> String:
	if len(POSSIBLE_SHOOT_MODES) == 0:
		return ""
	var mode = POSSIBLE_SHOOT_MODES[randi() % len(POSSIBLE_SHOOT_MODES)]
	return mode

func shoot() -> void:
	match shoot_mode:
		"circle":
			var bullet_count: int = randi() % 3 + 4
			var offset = 2.0 * PI * randf()
			for i in range(bullet_count):
				shoot_bullet(offset)
				offset += 2.0 * PI / bullet_count
		"target":
			# Shoot three bullets
			var spread: float = PI / 4.0 * randf() + PI / 3.0
			for i in range(3):
				shoot_bullet(spread * (i - 1) / 2.0)
		"rapid_fire":
			var bullet_count: int = 16 + randi() % 8
			for i in range(bullet_count):
				bullet_queue.push(0.1, 2.0 * PI * randf(), false)
			shoot_timer = bullet_count * 0.1 + 1.0
			shoot_mode = "target"
		"triple_spiral":
			var bullet_count: int = 20 + randi() % 10
			var offset = 2.0 * PI * randf()
			var bullet_dir: float
			if randi() % 2 == 0:
				bullet_dir = 1.0
			else:
				bullet_dir = -1.0
			for i in range(bullet_count):
				offset += PI / 8.0 * bullet_dir
				bullet_queue.push(0.2, offset, false)
				if randi() % 2 == 0:
					bullet_queue.push(0.02, offset + PI / 5.0, false)
					bullet_queue.push(0.02, offset - PI / 5.0, false)
				else:
					bullet_queue.push(0.02, offset - PI / 5.0, false)
					bullet_queue.push(0.02, offset + PI / 5.0, false)
			shoot_timer = bullet_count * 0.3 + 1.0
			shoot_mode = "target"
		_:
			shoot_bullet()

func _process(delta: float) -> void:
	update_shoot_mode_timer -= delta
	if update_shoot_mode_timer < 0.0:
		shoot_mode = get_random_shoot_mode()
		update_shoot_mode_timer = UPDATE_SHOOT_MODE_INTERVAL

	super._process(delta)
	if $/root/Main.lawn_loaded:
		bullet_queue.fire_bullet(
			delta,
			$/root/Main/Lawn,
			player,
			bullet_scene,
			bullet_spawn_point()
		)
