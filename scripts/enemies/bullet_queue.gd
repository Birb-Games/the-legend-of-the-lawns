class_name BulletQueue

class QueuedBullet:
	var time: float
	var angle: float
	var target_player: bool

	func _init(init_time: float, init_angle: float, init_target_player: bool) -> void:
		self.time = init_time
		self.angle = init_angle
		self.target_player = init_target_player

	func to_bullet(bullet_scene: PackedScene, spawn_point: Vector2, player_pos: Vector2) -> Node2D:
		var bullet = bullet_scene.instantiate()
		var dir: Vector2
		if target_player:
			var player_angle = (player_pos - spawn_point).angle() + angle
			dir = Vector2(cos(player_angle), sin(player_angle))
		else:	
			dir = Vector2(cos(angle), sin(angle))
		bullet.position = spawn_point
		bullet.dir = dir
		return bullet

var queued_bullet_list: Array[QueuedBullet] = []

# Pops a bullet from the front of the queue, returns the queued bullet data
# returns null if the queued bullet is not ready to fire, or if the queue is empty
func update(delta: float) -> QueuedBullet:	
	if queued_bullet_list.is_empty():
		return null

	queued_bullet_list[0].time -= delta
	if queued_bullet_list[0].time < 0.0:
		# NOTE: this does move all the elements that are still in the array
		# back by one which might have performance issues for very large arrays
		# *however* the array is not expected to be too large so the performance
		# hit likely will be negligible. If it does prove to be a problem,
		# this can be changed in the future.
		return queued_bullet_list.pop_front()
	return null

func fire_bullet(
	delta: float,
	lawn: Lawn,
	player: Player,
	bullet_scene: PackedScene,
	spawn_point: Vector2
) -> void:
	if player.health <= 0:
		return

	var queued: QueuedBullet = update(delta)

	if queued == null:
		return

	var bullet = queued.to_bullet(bullet_scene, spawn_point, player.global_position)
	lawn.add_child(bullet)

# Pushes a bullet to the back of the queue
func push(time: float, angle: float, target_player: bool) -> void:
	queued_bullet_list.push_back(QueuedBullet.new(time, angle, target_player))
