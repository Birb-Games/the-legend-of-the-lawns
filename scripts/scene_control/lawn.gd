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
# How much to increase the speed of spawning enemies
const DIFFICULTY_SPEED: float = 0.95
@export var max_weeds: int = 20
@export var max_mobs: int = 20
@onready var weed_spawn_timer: float = max(24.0 * pow(DIFFICULTY_SPEED, difficulty), 10.0)
@onready var weed_spawn_frequency: float = max(20.0 * pow(DIFFICULTY_SPEED, difficulty), 10.0)
@onready var mob_spawn_timer: float = max(32.0 * pow(DIFFICULTY_SPEED, difficulty), 15.0)
@onready var mob_spawn_frequency: float = max(32.0 * pow(DIFFICULTY_SPEED, difficulty), 15.0)
# Valid tiles that enemies  can spawn on
var valid_spawn_tiles: Dictionary

var finish_timer: float = 1.0

func _ready() -> void:
	tile_size = $TileMapLayer.tile_set.tile_size

	total_grass_tiles = 0
	var top_left: Vector2i = Vector2i.ZERO
	var bottom_right: Vector2i = Vector2i.ZERO
	var first: bool = true
	for cell in $TileMapLayer.get_used_cells():
		valid_spawn_tiles[cell] = true
		if first:
			top_left = cell
			bottom_right = cell
			first = false
		else:
			top_left.x = min(top_left.x, cell.x)
			top_left.y = min(top_left.y, cell.y)
			bottom_right.x = max(bottom_right.x, cell.x)
			bottom_right.y = max(bottom_right.y, cell.y)
		if LawnGenerationUtilities.is_grass($TileMapLayer.get_cell_atlas_coords(cell)):
			total_grass_tiles += 1
	bottom_right += Vector2i(1, 1)
	var used_rect: Rect2i = Rect2i(top_left, bottom_right - top_left)

	# Initialize the A* Grid
	astar_grid = AStarGrid2D.new()
	astar_grid.region = used_rect
	var tile_set: TileSet = $TileMapLayer.tile_set
	astar_grid.cell_size = tile_set.tile_size
	astar_grid.update()
	for cell in $TileMapLayer.get_used_cells():
		var tile_data: TileData = $TileMapLayer.get_cell_tile_data(cell)
		if tile_data == null:
			continue
		# Check if the tile has any polygons representing its collision, 
		# if it does, then mark it as a solid tile
		if tile_data.get_collision_polygons_count(0) > 0:
			astar_grid.set_point_solid(cell)

	LawnGenerationUtilities.set_outline($TileMapLayer, LawnGenerationUtilities.GRASS, 14)

func get_tile(x: int, y: int) -> Vector2i:
	return $TileMapLayer.get_cell_atlas_coords(Vector2i(x, y))

func is_valid_spawn_tile(x: int, y: int) -> bool:
	return Vector2i(x, y) in valid_spawn_tiles

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

func spawn_weeds(pos: Vector2) -> void:
	var weights = Spawning.get_weed_spawn_weights(max(difficulty - 1, 0))
	
	if weights.is_empty():
		return

	if $Weeds.get_child_count() >= max_weeds:
		return

	var spawn_count = Spawning.get_rand_weed_count(max(difficulty - 1, 0))
	for i in range(spawn_count):
		var enemy_id: String = Spawning.get_rand(weights)
		if enemy_id.is_empty():
			continue
		Spawning.try_spawning_around_point(
			self,
			$Weeds,
			pos,
			Spawning.get_weed_scene(enemy_id),
			3.0,
			8.0,
			2,
			0.2
		)

func spawn_mobs(pos: Vector2) -> void:	
	var weights = Spawning.get_mob_spawn_weights(difficulty)
	if weights.is_empty():
		return

	if $MobileEnemies.get_child_count() >= max_mobs:
		return

	var enemy_id: String = Spawning.get_rand(weights)
	var spawn_count = Spawning.get_rand_mob_count(max(difficulty - 1, 0), enemy_id)
	if enemy_id == "random":
		weights = Spawning.get_mob_spawn_weights(max(difficulty - 1, 0))
		for i in range(spawn_count):
			enemy_id = Spawning.get_rand(weights)
			if enemy_id.is_empty():
				continue
			Spawning.spawn_around_point(
				self,
				$MobileEnemies,
				pos,
				Spawning.get_mob_scene(enemy_id),
				4.0,
				12.0
			)
	elif !enemy_id.is_empty():
		for i in range(spawn_count):
			Spawning.spawn_around_point(
				self,
				$MobileEnemies,
				pos,
				Spawning.get_mob_scene(enemy_id),
				4.0,
				12.0
			)

func spawn_enemies(delta: float) -> void:
	var player: Player = get_node_or_null("/root/Main/Player")

	# Spawn tomato boy
	if tomato_boy_scene:
		tomato_boy_spawn_timer -= delta
	if tomato_boy_spawn_timer < 0.0 and randi() % 3 == 0:
		Spawning.try_spawning_around_point(
			self, 
			$MobileEnemies,
			player.global_position, 
			tomato_boy_scene,
			4.0,
			16.0,
			3,
		)
	if tomato_boy_spawn_timer < 0.0:
		tomato_boy_spawn_timer = randf_range(45.0, 120.0)
	
	if cut_grass_tiles >= total_grass_tiles:
		return
	
	# Spawn mobile enemies
	mob_spawn_timer -= delta
	if mob_spawn_timer <= 0.0:
		if randi() % 3 != 0:
			spawn_mobs(player.global_position)
		if randi() % 2 == 0:
			mob_spawn_frequency *= DIFFICULTY_SPEED
			mob_spawn_frequency = max(mob_spawn_frequency, 9.0)
		mob_spawn_timer = mob_spawn_frequency * randf_range(1.0, 1.5) + randf()

	# Spawn weed enemies
	weed_spawn_timer -= delta
	if weed_spawn_timer <= 0.0:
		if randi() % 3 != 0:
			spawn_weeds(player.global_position)
		weed_spawn_frequency *= DIFFICULTY_SPEED
		weed_spawn_frequency = max(weed_spawn_frequency, 5.0)
		weed_spawn_timer = weed_spawn_frequency * randf_range(1.0, 1.5) + randf()

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

	if player.health > 0:
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
			update_enemy_pathfinding()
			update_astar_grid = false
			print("Updated pathfinding grid for lawn.")
		astar_update_timer = ASTAR_UPDATE_INTERVAL

func get_spawn() -> Vector2:
	return $PlayerSpawn.position
