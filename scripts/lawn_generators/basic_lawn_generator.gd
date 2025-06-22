extends TileMapLayer

func _ready() -> void:
	for hedge_generation_point in $HedgeGenerationPoints.get_children():
		generate_hedge(hedge_generation_point)
	
	LawnGenerationUtilities.prune_hedges(self)
	
func generate_hedge(generation_point: Node2D) -> void:
	if randf() > generation_point.generation_chance:
		return
	
	var size: Vector2i = Vector2i(randi_range(generation_point.min_size.x, generation_point.max_size.x), randi_range(generation_point.min_size.y, generation_point.max_size.y))
	for i in range(size.x):
		for j in range(size.y):
			var current_tile: Vector2i = Vector2i(generation_point.position / 16) - (size / 2) + Vector2i(i, j)
			if get_cell_atlas_coords(current_tile) == Vector2i(1, 0):	
				set_cell(current_tile, 0, Vector2i(5, 1), 0)
