extends Sprite2D

# @onready var particles: GPUParticles2D = $GPUParticles2D
# @onready var raycast: RayCast2D = $RayCast2D

@onready var radius = (position - get_parent().get_node("AnimatedSprite2D").position).length()
@onready var player: Player = get_parent()
var size = scale.y

@export var bullet_scene: PackedScene
@export var fire_bullet_scene: PackedScene
@export var weedkiller_bullet_scene: PackedScene
@export var mega_bullet_scene: PackedScene
@export var ice_bullet_scene: PackedScene
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

# Return true if we can shoot a bullet
func shoot(angle_offset: float = 0.0) -> bool:
	var bullet: PlayerBullet
	if player.get_status_effect_time("fire") > 0.0:
		bullet = fire_bullet_scene.instantiate()
	else:	
		var selected: int = $/root/Main/HUD/Control/InventoryGUI.selected
		var selected_item: InventoryItem = player.inventory.get_item(selected)	
		if selected_item:
			match selected_item.id:
				"weedkiller":
					bullet = weedkiller_bullet_scene.instantiate()
					bullet.damage = 2
					selected_item.uses_left -= 1
				"acidic_weedkiller":
					if selected_item.cooldown > 0.0:
						return false
					bullet = weedkiller_bullet_scene.instantiate()
					bullet.modulate = Color8(255, 0, 255)
					bullet.damage = 3
					selected_item.uses_left -= 1
					selected_item.cooldown = InventoryItem.get_cooldown(selected_item.id)
				"super_weedkiller":
					if selected_item.cooldown > 0.0:
						return false
					bullet = weedkiller_bullet_scene.instantiate()
					bullet.modulate = Color8(0, 255, 255)
					bullet.damage = 4
					selected_item.uses_left -= 1
					selected_item.cooldown = InventoryItem.get_cooldown(selected_item.id)
				"ultra_weedkiller":
					if selected_item.cooldown > 0.0:
						return false
					bullet = weedkiller_bullet_scene.instantiate()
					bullet.modulate = Color8(255, 0, 0)
					bullet.damage = 5
					selected_item.uses_left -= 1
					selected_item.cooldown = InventoryItem.get_cooldown(selected_item.id)
				"water_jug":
					if selected_item.cooldown > 0.0:
						return false
					bullet = mega_bullet_scene.instantiate()
					selected_item.uses_left -= 1
					selected_item.cooldown = InventoryItem.get_cooldown(selected_item.id)
				"gasoline":
					if selected_item.cooldown > 0.0:
						return false
					bullet = fire_bullet_scene.instantiate()
					selected_item.uses_left -= 1
					selected_item.cooldown = InventoryItem.get_cooldown(selected_item.id)
				"ice":
					bullet = ice_bullet_scene.instantiate()
					selected_item.uses_left -= 1
				_:
					bullet = bullet_scene.instantiate()
			if selected_item.uses_left <= 0:
				player.inventory.remove_item(selected)
		else:
			bullet = bullet_scene.instantiate()
	bullet.dir = Vector2(cos(rotation + angle_offset), sin(rotation + angle_offset))
	bullet.position = $BulletSpawnPoint.global_position
	$/root/Main/Lawn.add_child(bullet)
	return true

func _process(delta: float) -> void:
	# particles.emitting = visible
	# raycast.enabled = visible
	
	shoot_timer -= delta
	
	if !visible:
		return
		
	update_transform()

	var npc_menu_open: bool = $/root/Main/HUD.npc_menu_open() and !$/root/Main/HUD.npc_menu_can_move()
	if shoot_timer <= 0.0 and Input.is_action_pressed("shoot_primary") and !npc_menu_open:
		var npc_menu = $/root/Main/HUD/Control/NPCMenu
		if npc_menu.mouse_inside() and $/root/Main/HUD.npc_menu_open():
			return
		var selected: int = $/root/Main/HUD/Control/InventoryGUI.selected
		var selected_item: InventoryItem = player.inventory.get_item(selected)
		if selected_item and selected_item.id == "water_bottle_pack":
			if selected_item.cooldown <= 0.0:
				shoot(-PI / 12.0)
				shoot(0.0)
				if shoot(PI / 12.0):
					$/root/Main.play_sfx("Shoot")
				selected_item.uses_left -= 1
				selected_item.cooldown = InventoryItem.get_cooldown(selected_item.id)
				if selected_item.uses_left <= 0:
					player.inventory.remove_item(selected)
		elif shoot():
			$/root/Main.play_sfx("Shoot")
		shoot_timer = SHOOT_COOLDOWN
		return
	
	# var shooting = Input.is_action_pressed("shoot_secondary")
	# particles.emitting = shooting
	# raycast.enabled = shooting
