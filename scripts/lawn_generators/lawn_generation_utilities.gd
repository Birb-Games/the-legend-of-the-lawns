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

# Give hedges their proper edges
static func prune_hedges(tileMapLayer: TileMapLayer) -> void:
	for tile in tileMapLayer.get_used_cells():
		if !is_hedge(tileMapLayer.get_cell_atlas_coords(tile)):
			continue
		
		# Check which of the neighbors is a hedge
		var neighbors: Array = [false, false, false, false, false, false, false, false]
		for i in range(neighbors.size()):
			neighbors[i] = is_hedge(tileMapLayer.get_cell_atlas_coords(tile + DIRECTIONS[i]))

		# Decide which hedge tile based on neighbors
		match neighbors:
			# No direct neighbors
			[false, false, false, false, _, _, _, _]:
				tileMapLayer.set_cell(tile, 0, Vector2i(1, 2), 0)

			# One direct neighbor
			[true, false, false, false, _, _, _, _]:
				tileMapLayer.set_cell(tile, 0, Vector2i(2, 2), 1)
			[false, true, false, false, _, _, _, _]:
				tileMapLayer.set_cell(tile, 0, Vector2i(2, 2), 0)
			[false, false, true, false, _, _, _, _]:
				tileMapLayer.set_cell(tile, 0, Vector2i(2, 2), 3)
			[false, false, false, true, _, _, _, _]:
				tileMapLayer.set_cell(tile, 0, Vector2i(2, 2), 2)

			# Two direct neighbors
			[false, true, false, true, _, _, _, false]:
				tileMapLayer.set_cell(tile, 0, Vector2i(3, 2), 0)
			[false, true, true, false, _, _, false, _]:
				tileMapLayer.set_cell(tile, 0, Vector2i(3, 2), 1)
			[true, false, false, true, _, false, _, _]:
				tileMapLayer.set_cell(tile, 0, Vector2i(3, 2), 2)
			[true, false, true, false, false, _, _, _]:
				tileMapLayer.set_cell(tile, 0, Vector2i(3, 2), 3)

			[false, true, false, true, _, _, _, true]:
				tileMapLayer.set_cell(tile, 0, Vector2i(3, 1), 0)
			[false, true, true, false, _, _, true, _]:
				tileMapLayer.set_cell(tile, 0, Vector2i(3, 1), 1)
			[true, false, false, true, _, true, _, _]:
				tileMapLayer.set_cell(tile, 0, Vector2i(3, 1), 2)
			[true, false, true, false, true, _, _, _]:
				tileMapLayer.set_cell(tile, 0, Vector2i(3, 1), 3)
			
			[true, true, false, false, _, _, _, _]:
				tileMapLayer.set_cell(tile, 0, Vector2i(4, 2), 1)
			[false, false, true, true, _, _, _, _]:
				tileMapLayer.set_cell(tile, 0, Vector2i(4, 2), 0)
			
			# Three direct neighbors
			[false, true, true, true, _, _, false, false]:
				tileMapLayer.set_cell(tile, 0, Vector2i(5, 2), 0)
			[true, false, true, true, false, false, _, _]:
				tileMapLayer.set_cell(tile, 0, Vector2i(5, 2), 1)
			[true, true, false, true, _, false, _, false]:
				tileMapLayer.set_cell(tile, 0, Vector2i(5, 2), 2)
			[true, true, true, false, false, _, false, _]:
				tileMapLayer.set_cell(tile, 0, Vector2i(5, 2), 3)

			[false, true, true, true, _, _, false, true]:
				tileMapLayer.set_cell(tile, 0, Vector2i(6, 2), 0)
			[false, true, true, true, _, _, true, false]:
				tileMapLayer.set_cell(tile, 0, Vector2i(6, 2), 1)
			[true, false, true, true, false, true, _, _]:
				tileMapLayer.set_cell(tile, 0, Vector2i(6, 2), 2)
			[true, false, true, true, true, false, _, _]:
				tileMapLayer.set_cell(tile, 0, Vector2i(6, 2), 3)
			[true, true, false, true, _, false, _, true]:
				tileMapLayer.set_cell(tile, 0, Vector2i(6, 2), 4)
			[true, true, false, true, _, true, _, false]:
				tileMapLayer.set_cell(tile, 0, Vector2i(6, 2), 6)
			[true, true, true, false, false, _, true, _]:
				tileMapLayer.set_cell(tile, 0, Vector2i(6, 2), 5)
			[true, true, true, false, true, _, false, _]:
				tileMapLayer.set_cell(tile, 0, Vector2i(6, 2), 7)
			
			[false, true, true, true, _, _, true, true]:
				tileMapLayer.set_cell(tile, 0, Vector2i(4, 1), 0)
			[true, false, true, true, true, true, _, _]:
				tileMapLayer.set_cell(tile, 0, Vector2i(4, 1), 1)
			[true, true, false, true, _, true, _, true]:
				tileMapLayer.set_cell(tile, 0, Vector2i(4, 1), 2)
			[true, true, true, false, true, _, true, _]:
				tileMapLayer.set_cell(tile, 0, Vector2i(4, 1), 3)
			
			# Four direct neighbors
			[true, true, true, true, false, false, false, false]:
				tileMapLayer.set_cell(tile, 0, Vector2i(7, 2), 0)
			
			[true, true, true, true, true, false, false, false]:
				tileMapLayer.set_cell(tile, 0, Vector2i(0, 3), 3)
			[true, true, true, true, false, true, false, false]:
				tileMapLayer.set_cell(tile, 0, Vector2i(0, 3), 2)
			[true, true, true, true, false, false, true, false]:
				tileMapLayer.set_cell(tile, 0, Vector2i(0, 3), 1)
			[true, true, true, true, false, false, false, true]:
				tileMapLayer.set_cell(tile, 0, Vector2i(0, 3), 0)
			
			[true, true, true, true, true, true, false, false]:
				tileMapLayer.set_cell(tile, 0, Vector2i(1, 3), 1)
			[true, true, true, true, false, false, true, true]:
				tileMapLayer.set_cell(tile, 0, Vector2i(1, 3), 0)
			[true, true, true, true, true, false, true, false]:
				tileMapLayer.set_cell(tile, 0, Vector2i(1, 3), 3)
			[true, true, true, true, false, true, false, true]:
				tileMapLayer.set_cell(tile, 0, Vector2i(1, 3), 2)

			[true, true, true, true, true, false, false, true]:
				tileMapLayer.set_cell(tile, 0, Vector2i(2, 3), 0)
			[true, true, true, true, false, true, true, false]:
				tileMapLayer.set_cell(tile, 0, Vector2i(2, 3), 1)
			
			[true, true, true, true, false, true, true, true]:
				tileMapLayer.set_cell(tile, 0, Vector2i(6, 1), 0)
			[true, true, true, true, true, false, true, true]:
				tileMapLayer.set_cell(tile, 0, Vector2i(6, 1), 1)
			[true, true, true, true, true, true, false, true]:
				tileMapLayer.set_cell(tile, 0, Vector2i(6, 1), 2)
			[true, true, true, true, true, true, true, false]:
				tileMapLayer.set_cell(tile, 0, Vector2i(6, 1), 3)

			[true, true, true, true, true, true, true, true]:
				pass

			_:
				printerr("Invalid hedge placement at ", tile)

static func is_hedge(atlas_coords: Vector2i) -> bool:
	# Check if the tile is a hedge
	return atlas_coords in HEDGE_TILES
