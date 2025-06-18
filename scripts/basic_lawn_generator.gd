extends TileMapLayer

func _ready() -> void:
	for hedge_generation_point in $HedgeGenerationPoints.get_children():
		generate_hedge(hedge_generation_point.position)
	
func generate_hedge(centerpoint: Vector2) -> void:
	self.set_cell(centerpoint / 16, 0, Vector2i(3, 1), 0)