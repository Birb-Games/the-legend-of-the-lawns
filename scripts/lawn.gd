extends Node2D

@onready var lawnmower: RigidBody2D

# Mows a grass tile
func mow_tile(pos: Vector2i):
	var cell_atlas = $TileMapLayer.get_cell_atlas_coords(pos)
	if cell_atlas != Vector2i(1, 0):
		return
	$TileMapLayer.set_cell(pos, 0, Vector2i(0, 0), 0)

func _process(delta: float) -> void:
	if not mower_exists():
		return
	
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

func mower_exists() -> bool:
	lawnmower = get_node_or_null("/root/Main/Lawnmower")
	return lawnmower != null and lawnmower.is_inside_tree()
