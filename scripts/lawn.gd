extends Node2D

@export var lawnmower: RigidBody2D

var total_grass_tiles: int
var cut_grass_tiles: int = 0

func _ready() -> void:
	total_grass_tiles = 0
	for cell in $TileMapLayer.get_used_cells():
		if $TileMapLayer.get_cell_atlas_coords(cell) == Vector2i(1, 0):
			total_grass_tiles += 1	

# Mows a grass tile
func mow_tile(pos: Vector2i):
	var cell_atlas = $TileMapLayer.get_cell_atlas_coords(pos)
	if cell_atlas != Vector2i(1, 0):
		return
	$TileMapLayer.set_cell(pos, 0, Vector2i(0, 0), 0)
	cut_grass_tiles += 1
	$/root/Main/HUD.update_progress_bar(float(cut_grass_tiles) / float(total_grass_tiles))

func destroy_hedge(pos: Vector2i):
	var cell_atlas = $TileMapLayer.get_cell_atlas_coords(pos)
	var hedges = [Vector2i(3, 1), Vector2i(4, 1), Vector2i(5, 1), Vector2i(6, 1)]
	var found = false
	for hedge in hedges:
		if cell_atlas == hedge:
			found = true
	if !found:
		return
	$TileMapLayer.set_cell(pos, 0, Vector2i(0, 2), 0)

func _process(_delta: float) -> void:
	# Mow the lawn
	var tile_sz = float($TileMapLayer.tile_set.tile_size.x)
	var lawnmower_pos = lawnmower.position / tile_sz - Vector2(0.5, 0.5)
	var positions = []
	for dx in range(-1, 2):
		for dy in range(-1, 2):
			var x = lawnmower_pos.x + 0.25 * dx
			var y = lawnmower_pos.y + 0.25 * dy
			var p = Vector2i(round(x), round(y))
			positions.push_back(p)
	for pos in positions:
		mow_tile(pos)
	
	# destroy hedges
	positions = []
	var dir_vec = lawnmower.get_dir_vec()
	var mower_rect = lawnmower.rect()
	mower_rect.size /= tile_sz
	mower_rect.position /= tile_sz
	for dx in range(-1, 2):
		for dy in range(-1, 2):
			var tile_rect = Rect2(
				round(lawnmower_pos.x) + dx,
				round(lawnmower_pos.y) + dy,
				1.0,
				1.0,
			)
			if !tile_rect.intersects(mower_rect):
				continue
			var p = Vector2i(round(lawnmower_pos.x) + dx, round(lawnmower_pos.y) + dy)
			positions.push_back(p)
	for pos in positions:
		destroy_hedge(pos)
