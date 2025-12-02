extends Node2D

@onready var lawnmower: Lawnmower = $Lawnmower
@onready var water_gun_item: StaticBody2D = $WaterGun

# In seconds, if the player mows the lawn in under this amount of time then
# they get a time bonus
@export var time_limit: float = 120.0;

var total_grass_tiles: int
var cut_grass_tiles: int = 0

# Keep track of the number of flowers destroyed for the penalty
var flowers_destroyed: int = 0

func _ready() -> void:
	total_grass_tiles = 0
	for cell in $TileMapLayer.get_used_cells():
		if $TileMapLayer.get_cell_atlas_coords(cell) == Vector2i(1, 0):
			total_grass_tiles += 1

func get_perc_cut() -> float:
	return float(cut_grass_tiles) / float(total_grass_tiles)

# Mows a grass tile
func mow_tile(pos: Vector2i) -> void:
	var cell_atlas = $TileMapLayer.get_cell_atlas_coords(pos)
	if cell_atlas != Vector2i(1, 0):
		return
	$TileMapLayer.set_cell(pos, 0, Vector2i(0, 0), 0)
	cut_grass_tiles += 1

# Returns true if a hedge has been destroyed, false otherwise
func destroy_hedge(pos: Vector2i) -> bool:
	var cell_atlas = $TileMapLayer.get_cell_atlas_coords(pos)
	if !LawnGenerationUtilities.is_hedge(cell_atlas):
		# No hedge
		return false
	$TileMapLayer.set_cell(pos, 0, Vector2i(0, 2), 0)
	PenaltyParticle.emit_penalty(
		$/root/Main/HUD.get_current_neighbor().hedge_penalty, 
		pos * $TileMapLayer.tile_set.tile_size, $/root/Main/Lawn
	)
	return true

# Have the player pick up the water gun
func pickup_water_gun() -> void:
	if !water_gun_item.is_inside_tree():
		return
	var player: Player = get_node_or_null("/root/Main/Player")
	if player == null:
		return
	if !player.can_pick_up_water_gun:
		return
	if Input.is_action_just_pressed("interact") and !player.lawn_mower_active():
		remove_child(water_gun_item)
		player.enable_water_gun()

func drop_water_gun() -> void:
	var player: Player = get_node_or_null("/root/Main/Player")
	if player == null:
		return
	if !player.get_node("WaterGun").visible:
		return
	if Input.is_action_just_pressed("interact"):
		water_gun_item.position = player.get_sprite_pos() + Vector2(0.0, 12.0)
		add_child(water_gun_item)
		player.disable_water_gun()

func water_gun_interaction() -> void:
	if water_gun_item.is_inside_tree():
		pickup_water_gun()
	else:
		drop_water_gun()

func _process(_delta: float) -> void:
	if cut_grass_tiles >= total_grass_tiles:
		get_tree().paused = true
		$/root/Main/HUD.activate_finish_screen()
		return
	
	water_gun_interaction()

	var player: Player = get_node_or_null("/root/Main/Player")
	if player == null:
		return

	if !player.lawn_mower_active():
		return

	var tile_sz = float($TileMapLayer.tile_set.tile_size.x)
	var mower_rect = player.get_lawn_mower_rect()
	mower_rect.size /= tile_sz
	mower_rect.position /= tile_sz

	var positions = []	
	for dx in range(-2, 2 + 1):
		for dy in range(-2, 2 + 1):
			var x: int = floor(mower_rect.position.x) + dx
			var y: int = floor(mower_rect.position.y) + dy
			var tile_rect = Rect2(x, y, 1.0, 1.0)
			if !tile_rect.intersects(mower_rect):
				continue
			var p = Vector2i(x, y)
			positions.push_back(p)

	for pos in positions:
		mow_tile(pos)

	# destroy hedges	
	if player.lawn_mower_active():
		for pos in positions:
			if destroy_hedge(pos):
				player.activate_hedge_timer()

func get_spawn() -> Vector2:
	return $PlayerSpawn.position
