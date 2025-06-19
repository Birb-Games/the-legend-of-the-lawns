extends TileMapLayer

func _ready() -> void:
	for hedge_generation_point in $HedgeGenerationPoints.get_children():
		generate_hedge(hedge_generation_point.position / 16)
	
	prune_hedges()
	
func generate_hedge(centerpoint: Vector2i) -> void:
	# Create rectangle
	var hedge: TileMapPattern = TileMapPattern.new()
	var size: Vector2i = Vector2i(randi_range(1, 5), randi_range(2, 5))
	if size.x == 1:
		return #chance of no hedge at all
	for i in range(size.x):
		for j in range(size.y):
			hedge.set_cell(Vector2i(i, j), 0, Vector2i(5, 1), 0)

	# Place in lawn
	set_pattern(centerpoint - (hedge.get_size() / 2), hedge)

# Give hedges their proper edges
func prune_hedges() -> void:
	for tile in get_used_cells():
		if get_cell_atlas_coords(tile).x <= 6 and get_cell_atlas_coords(tile).x >= 3 and get_cell_atlas_coords(tile).y == 1:
			# Check which of the neighbors is a hedge
			var neighbors: Array = [false, false, false, false, false, false, false, false]
			neighbors[0] = (get_cell_atlas_coords(tile + Vector2i(0, -1)).x <= 6 and get_cell_atlas_coords(tile + Vector2i(0, -1)).x >= 3) and get_cell_atlas_coords(tile + Vector2i(0, -1)).y == 1 # Up
			neighbors[1] = (get_cell_atlas_coords(tile + Vector2i(0, 1)).x <= 6 and get_cell_atlas_coords(tile + Vector2i(0, 1)).x >= 3) and get_cell_atlas_coords(tile + Vector2i(0, 1)).y == 1   # Down
			neighbors[2] = (get_cell_atlas_coords(tile + Vector2i(-1, 0)).x <= 6 and get_cell_atlas_coords(tile + Vector2i(-1, 0)).x >= 3) and get_cell_atlas_coords(tile + Vector2i(-1, 0)).y == 1 # Left
			neighbors[3] = (get_cell_atlas_coords(tile + Vector2i(1, 0)).x <= 6 and get_cell_atlas_coords(tile + Vector2i(1, 0)).x >= 3) and get_cell_atlas_coords(tile + Vector2i(1, 0)).y == 1  # Right
			neighbors[4] = (get_cell_atlas_coords(tile + Vector2i(-1, -1)).x <= 6 and get_cell_atlas_coords(tile + Vector2i(-1, -1)).x >= 3) and get_cell_atlas_coords(tile + Vector2i(-1, -1)).y == 1 # Top Left
			neighbors[5] = (get_cell_atlas_coords(tile + Vector2i(1, -1)).x <= 6 and get_cell_atlas_coords(tile + Vector2i(1, -1)).x >= 3) and get_cell_atlas_coords(tile + Vector2i(1, -1)).y == 1  # Top Right
			neighbors[6] = (get_cell_atlas_coords(tile + Vector2i(-1, 1)).x <= 6 and get_cell_atlas_coords(tile + Vector2i(-1, 1)).x >= 3) and get_cell_atlas_coords(tile + Vector2i(-1, 1)).y == 1  # Bottom Left
			neighbors[7] = (get_cell_atlas_coords(tile + Vector2i(1, 1)).x <= 6 and get_cell_atlas_coords(tile + Vector2i(1, 1)).x >= 3) and get_cell_atlas_coords(tile + Vector2i(1, 1)).y == 1   # Bottom Right

			var neighbor_count: int = 0
			for i in neighbors:
				neighbor_count += int(i)
			
			if neighbor_count == 0 or neighbor_count == 1 or neighbor_count == 2:
				printerr("Invalid hedge placement at ", tile)
			elif neighbor_count == 3:
				if neighbors[4]:
					set_cell(tile, 0, Vector2i(3, 1), 3)
				elif neighbors[5]:
					set_cell(tile, 0, Vector2i(3, 1), 2)
				elif neighbors[6]:
					set_cell(tile, 0, Vector2i(3, 1), 1)
				elif neighbors[7]:
					set_cell(tile, 0, Vector2i(3, 1), 0)
			elif neighbor_count == 4:
				if neighbors[0] and neighbors[2]:
					set_cell(tile, 0, Vector2i(3, 1), 3)
				elif neighbors[0] and neighbors[3]:
					set_cell(tile, 0, Vector2i(3, 1), 2)
				elif neighbors[1] and neighbors[2]:
					set_cell(tile, 0, Vector2i(3, 1), 1)
				elif neighbors[1] and neighbors[3]:
					set_cell(tile, 0, Vector2i(3, 1), 0)
			elif neighbor_count == 5:
				if !neighbors[0] and neighbors[1] and neighbors[2] and neighbors[3]:
					set_cell(tile, 0, Vector2i(4, 1), 0)
				elif !neighbors[1] and neighbors[0] and neighbors[2] and neighbors[3]:
					set_cell(tile, 0, Vector2i(4, 1), 1)
				elif !neighbors[2] and neighbors[0] and neighbors[1] and neighbors[3]:
					set_cell(tile, 0, Vector2i(4, 1), 2)
				elif !neighbors[3] and neighbors[0] and neighbors[1] and neighbors[2]:
					set_cell(tile, 0, Vector2i(4, 1), 3)
				elif !neighbors[4]:
					set_cell(tile, 0, Vector2i(3, 1), 0)
				elif !neighbors[5]:
					set_cell(tile, 0, Vector2i(3, 1), 1)
				elif !neighbors[6]:
					set_cell(tile, 0, Vector2i(3, 1), 2)
				elif !neighbors[7]:
					set_cell(tile, 0, Vector2i(3, 1), 3)
			elif neighbor_count == 6:
				if !neighbors[0]:
					set_cell(tile, 0, Vector2i(4, 1), 0)
				elif !neighbors[1]:
					set_cell(tile, 0, Vector2i(4, 1), 1)
				elif !neighbors[2]:
					set_cell(tile, 0, Vector2i(4, 1), 2)
				elif !neighbors[3]:
					set_cell(tile, 0, Vector2i(4, 1), 3)
			elif neighbor_count == 7:
				if !neighbors[0]:
					set_cell(tile, 0, Vector2i(4, 1), 0)
				elif !neighbors[1]:
					set_cell(tile, 0, Vector2i(4, 1), 1)
				elif !neighbors[2]:
					set_cell(tile, 0, Vector2i(4, 1), 2)
				elif !neighbors[3]:
					set_cell(tile, 0, Vector2i(4, 1), 3)
				elif !neighbors[4]:
					set_cell(tile, 0, Vector2i(6, 1), 0)
				elif !neighbors[5]:
					set_cell(tile, 0, Vector2i(6, 1), 1)
				elif !neighbors[6]:
					set_cell(tile, 0, Vector2i(6, 1), 2)
				elif !neighbors[7]:
					set_cell(tile, 0, Vector2i(6, 1), 3)
				
