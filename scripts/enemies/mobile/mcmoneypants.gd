extends SecurityGuard

@onready var hud = $/root/Main/HUD
var hostile_timer: float = 4.0

func hostile() -> bool:
	if lawn is FinalBossLawn:
		return !lawn.begin_dialog and !lawn.intro and !hud.npc_menu_open()
	return true

func set_sprite_dir() -> void:
	if $AnimatedSprite2D.animation == "walking" or $AnimatedSprite2D.animation == "idle":
		set_dir_right()
		return
	super.set_sprite_dir()

func shoot() -> void:
	if !hostile() and hostile_timer > 0.0:
		return
	super.shoot()
	shoot_bullet(-PI / 6.0)
	shoot_bullet(PI / 6.0)

func calculate_velocity() -> Vector2:
	if !hostile() and hostile_timer > 0.0:
		return Vector2.ZERO
	return super.calculate_velocity()

func _process(delta: float) -> void:
	if !hostile():
		$Gun.hide()
	else:
		$Gun.show()
	if hostile_timer > 0.0:
		shoot_timer = 0.5
	if hostile() and hostile_timer > 0.0:
		hostile_timer -= delta
	super._process(delta)
	modulate.a = 1.0
