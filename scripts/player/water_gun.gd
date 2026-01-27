extends Sprite2D

# @onready var particles: GPUParticles2D = $GPUParticles2D
# @onready var raycast: RayCast2D = $RayCast2D

@onready var radius = (position - get_parent().get_node("AnimatedSprite2D").position).length()
@onready var player: Player = get_parent()
var size = scale.y

@export var bullet_scene: PackedScene
@export var fire_bullet_scene: PackedScene
var SHOOT_COOLDOWN: float = 0.25
var shoot_timer: float = 0.0

func _ready() -> void:
	hide()

func update_transform() -> void:
	var player_pos = get_parent().get_node("AnimatedSprite2D").position
	var global_player_pos = get_parent().position + player_pos
	position = (get_global_mouse_position() - global_player_pos).normalized() * radius + player_pos
	rotation = (get_global_mouse_position() - global_player_pos).normalized().angle()
	if abs(rotation) < PI / 2:
		scale.y = size
	else:
		scale.y = -size

func _process(delta: float) -> void:
	# particles.emitting = visible
	# raycast.enabled = visible
	
	shoot_timer -= delta
	
	if !visible:
		return
		
	update_transform()

	if shoot_timer <= 0.0 and Input.is_action_pressed("shoot_primary"):
		$/root/Main.play_sfx("Shoot")
		var bullet 
		if player.get_status_effect_time("fire") > 0.0:
			bullet = fire_bullet_scene.instantiate()
		else:
			bullet = bullet_scene.instantiate()
		bullet.dir = Vector2(cos(rotation), sin(rotation))
		bullet.position = $BulletSpawnPoint.global_position
		$/root/Main/Lawn.add_child(bullet)
		shoot_timer = SHOOT_COOLDOWN
		return
	
	# var shooting = Input.is_action_pressed("shoot_secondary")
	# particles.emitting = shooting
	# raycast.enabled = shooting
