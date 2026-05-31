extends Lawn

class_name FinalBossLawn

@export var explosion_scene: PackedScene
@export var fire_scene: PackedScene
@onready var hud = $/root/Main/HUD
@onready var player: Player = $/root/Main/Player
var intro: bool = true
var begin_dialog: bool = false
@export_multiline var dialog: PackedStringArray
var current_dialog: int = 0

var dialog_action: Dictionary[int, Callable] = {
	19: explode_manager
}

func explode_manager() -> void:
	var explosion: Explosion = explosion_scene.instantiate()
	explosion.scale *= 0.5
	explosion.damage = 0
	explosion.global_position = $MrManager/ExplosionPos.global_position
	add_child(explosion)

	# Play explosion
	Sfx.play_at_pos($MrManager.global_position, "explosion", self)
	# Add fire
	var fire: Fire = fire_scene.instantiate()
	fire.global_position = $MrManager.global_position
	add_child(fire)
	for i in range(5):
		var dist: float = randf_range(0.5, 1.25)
		var angle: float = randf_range(0.0, 2.0 * PI)
		var dir: Vector2 = Vector2(cos(angle), sin(angle))
		var fire_position: Vector2 = $MrManager.global_position + dist * dir * tile_size
		var tile_x: int = int(floor(fire_position.x / tile_size.x))
		var tile_y: int = int(floor(fire_position.y / tile_size.y))
		if !(Vector2i(tile_x, tile_y) in valid_spawn_tiles):
			continue
		fire = fire_scene.instantiate()
		fire.global_position = fire_position
		add_child(fire)
	
	$MrManager.queue_free()

func _ready() -> void:
	super._ready()
	$Spawners/Boss.spawn()
	$Spawners/Boss.can_spawn = false
	player.can_move = false
	player.automatically_move = true

func on_finish() -> void:
	super.on_finish()
	var main: Main = $/root/Main
	main.music_controller.clear_music()

func _process(delta: float) -> void:
	super._process(delta)

	# Code for the intro
	if intro:
		player.target_velocity = player.NORMAL_SPEED * Vector2.UP
		player.dir = "up"
		player.can_move = false
		player.automatically_move = true
		if player.global_position.y <= $Stop.global_position.y:
			intro = false
			player.automatically_move = false
			begin_dialog = true
	elif begin_dialog and !hud.npc_menu_open():
		player.can_move = false
		if current_dialog >= dialog.size():
			begin_dialog = false
			player.can_move = true
			var main: Main = $/root/Main
			main.music_controller.play_music("FinalBossMusic")
			return

		var dialog_str: String = dialog[current_dialog]
		if current_dialog in dialog_action:
			dialog_action[current_dialog].call()
		var dialog_parts: PackedStringArray = dialog_str.split("\n")
		if dialog_parts.size() < 3:
			current_dialog += 1
		else:
			current_dialog += 1
			$Talk.play()
			var dialog_text: String = ""
			for i in range(1, dialog_parts.size() - 1):
				dialog_text += dialog_parts[i]
				if i != dialog_parts.size() - 2:
					dialog_text += "\n"
			hud.alert(dialog_parts[0], dialog_text, dialog_parts[dialog_parts.size() - 1])	
