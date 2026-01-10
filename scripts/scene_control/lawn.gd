class_name Lawn

extends Node2D

@onready var lawnmower: Lawnmower = $Lawnmower
@onready var water_gun_item: StaticBody2D = $WaterGun
@onready var tile_size: Vector2

# In seconds, if the player mows the lawn in under this amount of time then
# they get a time bonus
@export var time_limit: float = 120.0;

@export var difficulty: int = 0

var total_grass_tiles: int
var cut_grass_tiles: int = 0

# Keep track of the number of flowers destroyed for the penalty
var flowers_destroyed: int = 0

var weeds_killed: int = 0
var total_weeds: int = 0
var weeds: Array[NodePath]

var astar_grid: AStarGrid2D
# Whether we should update the A* grid
var update_astar_grid: bool = false
const ASTAR_UPDATE_INTERVAL: float = 1.0
var astar_update_timer: float = ASTAR_UPDATE_INTERVAL

# Enemy spawning
@export var tomato_boy_scene: PackedScene
@onready var tomato_boy_spawn_timer = randf_range(45.0, 90.0)

var finish_timer: float = 1.0

func _ready() -> void:
	tile_size = $TileMapLayer.tile_set.tile_size

	total_grass_tiles = 0
	var used_rect: Rect2i = Rect2i(0, 0, 0, 0)
	var first: bool = true
	for cell in $TileMapLayer.get_used_cells():
		if first:
			used_rect.position = cell
			used_rect.end = cell
			first = false
		else:
			used_rect.position.x = min(used_rect.position.x, cell.x)
			used_rect.position.y = min(used_rect.position.y, cell.y)
			used_rect.end.x = max(used_rect.end.x, cell.x)
			used_rect.end.y = max(used_rect.end.y, cell.y)
		if $TileMapLayer.get_cell_atlas_coords(cell) == Vector2i(1, 0):
			total_grass_tiles += 1
	
	# Initialize the A* Grid
	astar_grid = AStarGrid2D.new()
	astar_grid.region = used_rect
	var tile_set: TileSet = $TileMapLayer.tile_set
	astar_grid.cell_size = tile_set.tile_size
	astar_grid.update()
	for cell in $TileMapLayer.get_used_cells():
		var tile_data: TileData = $TileMapLayer.get_cell_tile_data(cell)
		# Check if the tile has any polygons representing its collision, 
		# if it does, then mark it as a solid tile
		if tile_data and tile_data.get_collision_polygons_count(0) > 0:
			astar_grid.set_point_solid(cell)
	astar_grid.update()

func get_tile(x: int, y: int) -> Vector2i:
	return $TileMapLayer.get_cell_atlas_coords(Vector2i(x, y))

func update_enemy_pathfinding() -> void:
	for child in $MobileEnemies.get_children():
		if child is MobileEnemy:	
			child.update_path()

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

func lawn_completed() -> bool:
	return cut_grass_tiles >= total_grass_tiles and weeds_killed >= total_weeds

func spawn_enemies(delta: float) -> void:
	var player: Player = get_node_or_null("/root/Main/Player")

	if tomato_boy_scene:
		tomato_boy_spawn_timer -= delta
	if tomato_boy_spawn_timer < 0.0 and randi() % 2 == 0:
		Spawning.try_spawning_around_point(
			self, 
			$MobileEnemies,
			player.global_position, 
			tomato_boy_scene,
			4.0,
			16.0,
			3
		)
	if tomato_boy_spawn_timer < 0.0:
		tomato_boy_spawn_timer = randf_range(45.0, 90.0)


func _process(delta: float) -> void:
	var player: Player = get_node_or_null("/root/Main/Player")

	if player == null:
		return

	if lawn_completed() and player != null and player.health > 0:
		finish_timer -= delta
		finish_timer = max(finish_timer, 0.0)

	if lawn_completed() and finish_timer <= 0.0:
		get_tree().paused = true
		$/root/Main/HUD.activate_finish_screen()
		return

	spawn_enemies(delta)
	water_gun_interaction()

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
				update_astar_grid = true
				astar_grid.set_point_solid(pos, false)
				player.activate_hedge_timer()
	
	astar_update_timer -= delta
	if astar_update_timer <= 0.0:
		if update_astar_grid:
			astar_grid.update()
			update_enemy_pathfinding()
			update_astar_grid = false
			print("Updated pathfinding grid for lawn.")
		astar_update_timer = ASTAR_UPDATE_INTERVAL

func get_spawn() -> Vector2:
	return $PlayerSpawn.position
