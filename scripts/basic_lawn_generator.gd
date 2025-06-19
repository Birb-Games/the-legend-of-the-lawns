extends TileMapLayer

func _ready() -> void:
	for hedge_generation_point in $HedgeGenerationPoints.get_children():
		generate_hedge(hedge_generation_point.position / 16)
	
func generate_hedge(centerpoint: Vector2i) -> void:
	# Create rectangle
	var hedge: TileMapPattern = TileMapPattern.new()
	var size: Vector2i = Vector2i(randi_range(1, 5), randi_range(2, 5))
	if size.x == 1:
		return #chance of no hedge at all
	for i in range(size.x):
		for j in range(size.y):
			hedge.set_cell(Vector2i(i, j), 0, Vector2i(5, 1), 0)

	# Set edges
	for i in range(size.x):
		hedge.set_cell(Vector2i(i, 0), 0, Vector2i(4, 1), 0)
		hedge.set_cell(Vector2i(i, size.y - 1), 0, Vector2i(4, 1), 1)
	for j in range(size.y):
		hedge.set_cell(Vector2i(0, j), 0, Vector2i(4, 1), 2)
		hedge.set_cell(Vector2i(size.x - 1, j), 0, Vector2i(4, 1), 3)
	
	# Set corners
	hedge.set_cell(Vector2i(0, 0), 0, Vector2i(3, 1), 0)
	hedge.set_cell(Vector2i(size.x - 1, 0), 0, Vector2i(3, 1), 1)
	hedge.set_cell(Vector2i(0, size.y - 1), 0, Vector2i(3, 1), 2)
	hedge.set_cell(Vector2i(size.x - 1, size.y - 1), 0, Vector2i(3, 1), 3)

	# Place in lawn
	set_pattern(centerpoint - (hedge.get_size() / 2), hedge)
