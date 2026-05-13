extends WeedEnemy

@export var resist_particle_scene: PackedScene
@onready var lawn: Lawn = $/root/Main/Lawn
@onready var hud = $/root/Main/HUD
var hostile_timer: float = 2.0

func cut_scene_running() -> bool:
	if lawn is FinalBossLawn:
		return lawn.intro or (lawn.begin_dialog and hud.npc_menu_open())
	return false

func shoot() -> void:
	if hostile_timer > 0.0:
		return
	var bullet_count: int = randi_range(3, 6)
	for i in range(bullet_count):
		var offset = PI / 5.0 * (float(i) - float(bullet_count - 1) / 2.0)
		shoot_bullet(offset)

func damage(amt: int) -> void:
	if lawn.cut_grass_tiles <= lawn.total_grass_tiles:
		var resist = resist_particle_scene.instantiate()
		resist.global_position = global_position
		lawn.add_child(resist)
		return
	super.damage(amt)

func _process(delta: float) -> void:
	super._process(delta)
	if !cut_scene_running() and hostile_timer > 0.0:
		hostile_timer -= delta
