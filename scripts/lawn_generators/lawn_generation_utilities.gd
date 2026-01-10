extends Node
class_name LawnGenerationUtilities

# Used for neighbor checking
const DIRECTIONS: Array = [
	Vector2i.UP, 
	Vector2i.DOWN, 
	Vector2i.LEFT, 
	Vector2i.RIGHT,
	Vector2i(-1, -1), 
	Vector2i(1, -1), 
	Vector2i(-1, 1), 
	Vector2i(1, 1),
]

const HEDGE_TILES: Array = [
	Vector2i(3, 1), 
	Vector2i(4, 1), 
	Vector2i(5, 1), 
	Vector2i(6, 1),
	Vector2i(1, 2), 
	Vector2i(2, 2), 
	Vector2i(3, 2), 
	Vector2i(4, 2), 
	Vector2i(5, 2), 
	Vector2i(6, 2), 
	Vector2i(7, 2),
	Vector2i(0, 3), 
	Vector2i(1, 3), 
	Vector2i(2, 3),
]

# Coordinates in the tile set for a hedge tile
# (this points to an interior tile that should not be at the edge of a hedge
# formation, but the function `prune_hedges` should be able to fix this)
const HEDGE: Vector2i = Vector2i(5, 1)

# Give hedges their proper edges
static func prune_hedges(tilemap: TileMapLayer) -> void:
	for tile in tilemap.get_used_cells():
		if !is_hedge(tilemap.get_cell_atlas_coords(tile)):
			continue
		
		# Check which of the neighbors is a hedge
		var neighbors: Array = [false, false, false, false, false, false, false, false]
		for i in range(neighbors.size()):
			neighbors[i] = is_hedge(tilemap.get_cell_atlas_coords(tile + DIRECTIONS[i]))

		# Decide which hedge tile based on neighbors
		match neighbors:
			# No direct neighbors
			[false, false, false, false, _, _, _, _]:
				tilemap.set_cell(tile, 0, Vector2i(1, 2), 0)

			# One direct neighbor
			[true, false, false, false, _, _, _, _]:
				tilemap.set_cell(tile, 0, Vector2i(2, 2), 1)
			[false, true, false, false, _, _, _, _]:
				tilemap.set_cell(tile, 0, Vector2i(2, 2), 0)
			[false, false, true, false, _, _, _, _]:
				tilemap.set_cell(tile, 0, Vector2i(2, 2), 3)
			[false, false, false, true, _, _, _, _]:
				tilemap.set_cell(tile, 0, Vector2i(2, 2), 2)

			# Two direct neighbors
			[false, true, false, true, _, _, _, false]:
				tilemap.set_cell(tile, 0, Vector2i(3, 2), 0)
			[false, true, true, false, _, _, false, _]:
				tilemap.set_cell(tile, 0, Vector2i(3, 2), 1)
			[true, false, false, true, _, false, _, _]:
				tilemap.set_cell(tile, 0, Vector2i(3, 2), 2)
			[true, false, true, false, false, _, _, _]:
				tilemap.set_cell(tile, 0, Vector2i(3, 2), 3)

			[false, true, false, true, _, _, _, true]:
				tilemap.set_cell(tile, 0, Vector2i(3, 1), 0)
			[false, true, true, false, _, _, true, _]:
				tilemap.set_cell(tile, 0, Vector2i(3, 1), 1)
			[true, false, false, true, _, true, _, _]:
				tilemap.set_cell(tile, 0, Vector2i(3, 1), 2)
			[true, false, true, false, true, _, _, _]:
				tilemap.set_cell(tile, 0, Vector2i(3, 1), 3)
			
			[true, true, false, false, _, _, _, _]:
				tilemap.set_cell(tile, 0, Vector2i(4, 2), 1)
			[false, false, true, true, _, _, _, _]:
				tilemap.set_cell(tile, 0, Vector2i(4, 2), 0)
			
			# Three direct neighbors
			[false, true, true, true, _, _, false, false]:
				tilemap.set_cell(tile, 0, Vector2i(5, 2), 0)
			[true, false, true, true, false, false, _, _]:
				tilemap.set_cell(tile, 0, Vector2i(5, 2), 1)
			[true, true, false, true, _, false, _, false]:
				tilemap.set_cell(tile, 0, Vector2i(5, 2), 2)
			[true, true, true, false, false, _, false, _]:
				tilemap.set_cell(tile, 0, Vector2i(5, 2), 3)

			[false, true, true, true, _, _, false, true]:
				tilemap.set_cell(tile, 0, Vector2i(6, 2), 0)
			[false, true, true, true, _, _, true, false]:
				tilemap.set_cell(tile, 0, Vector2i(6, 2), 1)
			[true, false, true, true, false, true, _, _]:
				tilemap.set_cell(tile, 0, Vector2i(6, 2), 2)
			[true, false, true, true, true, false, _, _]:
				tilemap.set_cell(tile, 0, Vector2i(6, 2), 3)
			[true, true, false, true, _, false, _, true]:
				tilemap.set_cell(tile, 0, Vector2i(6, 2), 4)
			[true, true, false, true, _, true, _, false]:
				tilemap.set_cell(tile, 0, Vector2i(6, 2), 6)
			[true, true, true, false, false, _, true, _]:
				tilemap.set_cell(tile, 0, Vector2i(6, 2), 5)
			[true, true, true, false, true, _, false, _]:
				tilemap.set_cell(tile, 0, Vector2i(6, 2), 7)
			
			[false, true, true, true, _, _, true, true]:
				tilemap.set_cell(tile, 0, Vector2i(4, 1), 0)
			[true, false, true, true, true, true, _, _]:
				tilemap.set_cell(tile, 0, Vector2i(4, 1), 1)
			[true, true, false, true, _, true, _, true]:
				tilemap.set_cell(tile, 0, Vector2i(4, 1), 2)
			[true, true, true, false, true, _, true, _]:
				tilemap.set_cell(tile, 0, Vector2i(4, 1), 3)
			
			# Four direct neighbors
			[true, true, true, true, false, false, false, false]:
				tilemap.set_cell(tile, 0, Vector2i(7, 2), 0)
			
			[true, true, true, true, true, false, false, false]:
				tilemap.set_cell(tile, 0, Vector2i(0, 3), 3)
			[true, true, true, true, false, true, false, false]:
				tilemap.set_cell(tile, 0, Vector2i(0, 3), 2)
			[true, true, true, true, false, false, true, false]:
				tilemap.set_cell(tile, 0, Vector2i(0, 3), 1)
			[true, true, true, true, false, false, false, true]:
				tilemap.set_cell(tile, 0, Vector2i(0, 3), 0)
			
			[true, true, true, true, true, true, false, false]:
				tilemap.set_cell(tile, 0, Vector2i(1, 3), 1)
			[true, true, true, true, false, false, true, true]:
				tilemap.set_cell(tile, 0, Vector2i(1, 3), 0)
			[true, true, true, true, true, false, true, false]:
				tilemap.set_cell(tile, 0, Vector2i(1, 3), 3)
			[true, true, true, true, false, true, false, true]:
				tilemap.set_cell(tile, 0, Vector2i(1, 3), 2)

			[true, true, true, true, true, false, false, true]:
				tilemap.set_cell(tile, 0, Vector2i(2, 3), 0)
			[true, true, true, true, false, true, true, false]:
				tilemap.set_cell(tile, 0, Vector2i(2, 3), 1)
			
			[true, true, true, true, false, true, true, true]:
				tilemap.set_cell(tile, 0, Vector2i(6, 1), 0)
			[true, true, true, true, true, false, true, true]:
				tilemap.set_cell(tile, 0, Vector2i(6, 1), 1)
			[true, true, true, true, true, true, false, true]:
				tilemap.set_cell(tile, 0, Vector2i(6, 1), 2)
			[true, true, true, true, true, true, true, false]:
				tilemap.set_cell(tile, 0, Vector2i(6, 1), 3)

			[true, true, true, true, true, true, true, true]:
				pass

			_:
				printerr("Invalid hedge placement at ", tile)

# Check if the tile is a hedge
static func is_hedge(atlas_coords: Vector2i) -> bool:
	return atlas_coords in HEDGE_TILES

# Check if the tile is a grass tile
static func is_grass(atlas_coords: Vector2i) -> bool:
	return atlas_coords == Vector2i(1, 0)

# Check if the tile is a grass tile
static func is_cut_grass(atlas_coords: Vector2i) -> bool:
	return atlas_coords == Vector2i(0, 0)
