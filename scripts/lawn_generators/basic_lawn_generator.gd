extends TileMapLayer

func _ready() -> void:
	for hedge_generation_point in $HedgeGenerationPoints.get_children():
		generate_hedge(hedge_generation_point)
	
	LawnGenerationUtilities.prune_hedges(self)

func generate_hedge(generation_point: Node2D) -> void:
	if randf() > generation_point.generation_chance:
		return
	
	# Generate random rectangular hedge formations of random size
	var sx: int = randi_range(generation_point.min_size.x, generation_point.max_size.x)
	var sy: int = randi_range(generation_point.min_size.y, generation_point.max_size.y)
	var size: Vector2i = Vector2i(sx, sy)
	# Set the hedge tiles
	for i in range(size.x):
		for j in range(size.y):
			var tile_x: int = int(generation_point.position.x / tile_set.tile_size.x)
			var tile_y: int = int(generation_point.position.y / tile_set.tile_size.y)
			var current_tile: Vector2i = Vector2i(tile_x, tile_y) - (size / 2) + Vector2i(i, j)
			var tile: Vector2i = get_cell_atlas_coords(current_tile)
			if LawnGenerationUtilities.is_grass(tile):
				set_cell(current_tile, 0, LawnGenerationUtilities.HEDGE, 0)
