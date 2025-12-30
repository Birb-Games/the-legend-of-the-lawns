# A script to control an animated shrub demon on the main menu

extends CharacterBody2D

const MARGIN: float = 128.0

func _ready() -> void:
	$Healthbar.hide()
	$AnimatedSprite2D.animation = "walking"
	$SpawnShadow.hide()
	$ContactDamageZone.disabled = true
	reset()

func reset() -> void:
	var viewport_rect: Rect2 = get_viewport_rect()

	var angle: float = 0.0
	var rand: int = randi() % 4	
	match rand:
		0:
			position.x = randf_range(MARGIN, viewport_rect.size.x - MARGIN)
			position.y = -MARGIN
			angle = randf_range(0.0, PI)
		1:
			position.x = randf_range(MARGIN, viewport_rect.size.x - MARGIN)
			position.y = viewport_rect.size.y + MARGIN
			angle = randf_range(PI, 2.0 * PI)
		2:	
			position.x = -MARGIN
			position.y = randf_range(MARGIN, viewport_rect.size.y - MARGIN)
			angle = randf_range(-PI / 2.0, PI / 2.0)
		3:
			position.x = viewport_rect.size.x + MARGIN
			position.y = randf_range(MARGIN, viewport_rect.size.y - MARGIN)	
			angle = randf_range(PI / 2.0, 3.0 * PI / 2.0)
	
	velocity = Vector2(cos(angle), sin(angle)) * randf_range(80.0, 160.0)

func _physics_process(_delta: float) -> void:
	move_and_slide()

	var viewport_rect: Rect2 = get_viewport_rect()
	if position.x < -MARGIN * 2.0 or position.x > viewport_rect.size.x + MARGIN * 2.0:
		reset()
	elif position.y < -MARGIN * 2.0 or position.y > viewport_rect.size.y + MARGIN * 2.0:
		reset()
