extends Thornweed

const POSSIBLE_SHOOT_MODES: Array[String] = [
	"circle",
	"triple",
	"spawn",
	"rapid_fire",
	"spiral",
]
var shoot_mode: String = ""
@export var mini_thornweed_scene: PackedScene
const UPDATE_SHOOT_MODE_INTERVAL: float = 4.0
var update_shoot_mode_timer: float = UPDATE_SHOOT_MODE_INTERVAL

class QueuedBullet:
	var time: float
	var angle: float
	var target_player: bool

	func _init(init_time: float, init_angle: float, init_target_player: bool) -> void:
		self.time = init_time
		self.angle = init_angle
		self.target_player = init_target_player

var bullet_queue: Array[QueuedBullet]

func _ready() -> void:
	super._ready()
	shoot_mode = "circle"

func get_random_shoot_mode() -> String:
	if health <= int(max_health / 2.0) and $Spawns.get_child_count() == 0:
		return "spawn"
	if len(POSSIBLE_SHOOT_MODES) == 0:
		return ""
	return POSSIBLE_SHOOT_MODES[randi() % len(POSSIBLE_SHOOT_MODES)]

func explode() -> void:
	for child in $Spawns.get_children():
		if child is Thornweed:
			child.explode()
	super.explode()

func shoot() -> void:
	match shoot_mode:
		"circle":
			# Shoot a random number of bullets in a circle pattern
			var bullet_count = 7 + randi() % 6
			var offset = randf() * 2.0 * PI
			for i in range(bullet_count):
				shoot_bullet(offset)
				offset += 2.0 * PI / bullet_count
		"triple":
			# Shoot like a normal thornweed
			super.shoot()
		"spawn":
			# Spawn 5 mini thornweeds in a circle
			if $Spawns.get_child_count() > 0:
				shoot_mode = "triple"
				return
			var offset = randf() * 2.0 * PI
			for i in range(5):
				var thornweed = mini_thornweed_scene.instantiate()
				thornweed.position = Vector2(cos(offset), sin(offset)) * 30.0
				$Spawns.add_child(thornweed)
				offset += 2.0 * PI / 5.0 
			shoot_mode = "triple"
		"rapid_fire":
			# Rapidly fire bullets targetting the player
			var bullet_count = randi() % 8 + 24
			for i in range(bullet_count):
				bullet_queue.push_back(QueuedBullet.new(0.1, 0.0, true))
			shoot_timer = bullet_count * 0.2 + 1.0
			shoot_mode = "triple"
		"spiral":
			# Shoot bullets in a spiral for a bit
			var bullet_count = randi() % 8 + 24
			var angle = 2.0 * PI * randf()
			var bullet_dir: float
			if randi() % 2 == 0:
				bullet_dir = 1.0
			else:
				bullet_dir = -1.0
			for i in range(bullet_count):
				angle += PI / 8.0 * bullet_dir
				bullet_queue.push_back(QueuedBullet.new(0.2, angle, false))
			shoot_timer = bullet_count * 0.3 + 1.0
			shoot_mode = "triple"
		_:
			shoot_bullet()

func update_bullet_queue(delta: float) -> void:
	if !$/root/Main.lawn_loaded:
		return

	if player.health <= 0:
		return

	if len(bullet_queue) == 0:
		return
	
	bullet_queue[len(bullet_queue) - 1].time -= delta
	if bullet_queue[len(bullet_queue) - 1].time < 0.0:
		if bullet_queue[len(bullet_queue) - 1].target_player:
			shoot_bullet(bullet_queue[len(bullet_queue) - 1].angle)
		else:
			var angle = bullet_queue[len(bullet_queue) - 1].angle
			var dir = Vector2(cos(angle), sin(angle))
			var bullet = bullet_scene.instantiate()
			bullet.position = $BulletSpawnPoint.global_position + dir * 4.0
			bullet.dir = dir
			$/root/Main/Lawn.add_child(bullet)
		bullet_queue.pop_back()

func _process(delta: float) -> void:
	if health <= int(max_health / 2.0) and $Spawns.get_child_count() == 0:
		shoot_timer = 0.0
		update_shoot_mode_timer = 0.0

	update_shoot_mode_timer -= delta
	if update_shoot_mode_timer < 0.0:
		shoot_mode = get_random_shoot_mode()
		update_shoot_mode_timer = UPDATE_SHOOT_MODE_INTERVAL

	super._process(delta)
	update_bullet_queue(delta)

func get_animation() -> String:
	return "default"
