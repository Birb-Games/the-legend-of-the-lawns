extends TileMapLayer

var test: Node2D

func _ready() -> void:
	for hedge_generation_point in $HedgeGenerationPoints.get_children():
		generate_hedge(hedge_generation_point)
	
	prune_hedges()
	
func generate_hedge(generation_point: Node2D) -> void:
	# Create rectangle
	var hedge: TileMapPattern = TileMapPattern.new()
	var size: Vector2i = Vector2i(randi_range(generation_point.min_size.x, generation_point.max_size.x), randi_range(generation_point.min_size.y, generation_point.max_size.y))
	for i in range(size.x):
		for j in range(size.y):
			hedge.set_cell(Vector2i(i, j), 0, Vector2i(5, 1), 0)

	# Place in lawn
	set_pattern(Vector2i(generation_point.position / 16) - (hedge.get_size() / 2), hedge)

# Give hedges their proper edges
func prune_hedges() -> void:
	for tile in get_used_cells():
		if is_hedge(get_cell_atlas_coords(tile)):
			# Check which of the neighbors is a hedge
			var neighbors: Array = [false, false, false, false, false, false, false, false]
			neighbors[0] = is_hedge(get_cell_atlas_coords(tile + Vector2i(0, -1))) # Up
			neighbors[1] = is_hedge(get_cell_atlas_coords(tile + Vector2i(0, 1)))   # Down
			neighbors[2] = is_hedge(get_cell_atlas_coords(tile + Vector2i(-1, 0))) # Left
			neighbors[3] = is_hedge(get_cell_atlas_coords(tile + Vector2i(1, 0)))  # Right
			neighbors[4] = is_hedge(get_cell_atlas_coords(tile + Vector2i(-1, -1))) # Top Left
			neighbors[5] = is_hedge(get_cell_atlas_coords(tile + Vector2i(1, -1)))  # Top Right
			neighbors[6] = is_hedge(get_cell_atlas_coords(tile + Vector2i(-1, 1)))  # Bottom Left
			neighbors[7] = is_hedge(get_cell_atlas_coords(tile + Vector2i(1, 1)))   # Bottom Right

			# Decide which hedge tile based on neighbors
			match neighbors:
				# No direct neighbors
				[false, false, false, false, _, _, _, _]:
					set_cell(tile, 0, Vector2i(1, 2), 0)

				# One direct neighbor
				[true, false, false, false, _, _, _, _]:
					set_cell(tile, 0, Vector2i(2, 2), 1)
				[false, true, false, false, _, _, _, _]:
					set_cell(tile, 0, Vector2i(2, 2), 0)
				[false, false, true, false, _, _, _, _]:
					set_cell(tile, 0, Vector2i(2, 2), 3)
				[false, false, false, true, _, _, _, _]:
					set_cell(tile, 0, Vector2i(2, 2), 2)

				# Two direct neighbors
				[false, true, false, true, _, _, _, false]:
					set_cell(tile, 0, Vector2i(3, 2), 0)
				[false, true, true, false, _, _, false, _]:
					set_cell(tile, 0, Vector2i(3, 2), 1)
				[true, false, false, true, _, false, _, _]:
					set_cell(tile, 0, Vector2i(3, 2), 2)
				[true, false, true, false, false, _, _, _]:
					set_cell(tile, 0, Vector2i(3, 2), 3)

				[false, true, false, true, _, _, _, true]:
					set_cell(tile, 0, Vector2i(3, 1), 0)
				[false, true, true, false, _, _, true, _]:
					set_cell(tile, 0, Vector2i(3, 1), 1)
				[true, false, false, true, _, true, _, _]:
					set_cell(tile, 0, Vector2i(3, 1), 2)
				[true, false, true, false, true, _, _, _]:
					set_cell(tile, 0, Vector2i(3, 1), 3)
				
				[true, true, false, false, _, _, _, _]:
					set_cell(tile, 0, Vector2i(4, 2), 1)
				[false, false, true, true, _, _, _, _]:
					set_cell(tile, 0, Vector2i(4, 2), 0)
				
				# Three direct neighbors
				[false, true, true, true, _, _, false, false]:
					set_cell(tile, 0, Vector2i(5, 2), 0)
				[true, false, true, true, false, false, _, _]:
					set_cell(tile, 0, Vector2i(5, 2), 1)
				[true, true, false, true, _, false, _, false]:
					set_cell(tile, 0, Vector2i(5, 2), 2)
				[true, true, true, false, false, _, false, _]:
					set_cell(tile, 0, Vector2i(5, 2), 3)

				[false, true, true, true, _, _, false, true]:
					set_cell(tile, 0, Vector2i(6, 2), 0)
				[false, true, true, true, _, _, true, false]:
					set_cell(tile, 0, Vector2i(6, 2), 1)
				[true, false, true, true, false, true, _, _]:
					set_cell(tile, 0, Vector2i(6, 2), 2)
				[true, false, true, true, true, false, _, _]:
					set_cell(tile, 0, Vector2i(6, 2), 3)
				[true, true, false, true, _, false, _, true]:
					set_cell(tile, 0, Vector2i(6, 2), 4)
				[true, true, false, true, _, true, _, false]:
					set_cell(tile, 0, Vector2i(6, 2), 6)
				[true, true, true, false, false, _, true, _]:
					set_cell(tile, 0, Vector2i(6, 2), 5)
				[true, true, true, false, true, _, false, _]:
					set_cell(tile, 0, Vector2i(6, 2), 7)
				
				[false, true, true, true, _, _, true, true]:
					set_cell(tile, 0, Vector2i(4, 1), 0)
				[true, false, true, true, true, true, _, _]:
					set_cell(tile, 0, Vector2i(4, 1), 1)
				[true, true, false, true, _, true, _, true]:
					set_cell(tile, 0, Vector2i(4, 1), 2)
				[true, true, true, false, true, _, true, _]:
					set_cell(tile, 0, Vector2i(4, 1), 3)
				
				# Four direct neighbors
				[true, true, true, true, false, false, false, false]:
					set_cell(tile, 0, Vector2i(7, 2), 0)
				
				[true, true, true, true, true, false, false, false]:
					set_cell(tile, 0, Vector2i(0, 3), 3)
				[true, true, true, true, false, true, false, false]:
					set_cell(tile, 0, Vector2i(0, 3), 2)
				[true, true, true, true, false, false, true, false]:
					set_cell(tile, 0, Vector2i(0, 3), 1)
				[true, true, true, true, false, false, false, true]:
					set_cell(tile, 0, Vector2i(0, 3), 0)
				
				[true, true, true, true, true, true, false, false]:
					set_cell(tile, 0, Vector2i(1, 3), 1)
				[true, true, true, true, false, false, true, true]:
					set_cell(tile, 0, Vector2i(1, 3), 0)
				[true, true, true, true, true, false, true, false]:
					set_cell(tile, 0, Vector2i(1, 3), 3)
				[true, true, true, true, false, true, false, true]:
					set_cell(tile, 0, Vector2i(1, 3), 2)

				[true, true, true, true, true, false, false, true]:
					set_cell(tile, 0, Vector2i(2, 3), 0)
				[true, true, true, true, false, true, true, false]:
					set_cell(tile, 0, Vector2i(2, 3), 1)
				
				[true, true, true, true, false, true, true, true]:
					set_cell(tile, 0, Vector2i(6, 1), 0)
				[true, true, true, true, true, false, true, true]:
					set_cell(tile, 0, Vector2i(6, 1), 1)
				[true, true, true, true, true, true, false, true]:
					set_cell(tile, 0, Vector2i(6, 1), 2)
				[true, true, true, true, true, true, true, false]:
					set_cell(tile, 0, Vector2i(6, 1), 3)

				[true, true, true, true, true, true, true, true]:
					pass

				_:
					printerr("Invalid hedge placement at ", tile)

func is_hedge(atlas_coords: Vector2i) -> bool:
	# Check if the tile is a hedge
	return (atlas_coords.y == 1 and atlas_coords.x >= 3 and atlas_coords.x <= 6) or (atlas_coords.y == 2 and atlas_coords.x >= 1 and atlas_coords.x <= 7) or (atlas_coords.y == 3 and atlas_coords.x >= 0 and atlas_coords.x <= 2)
