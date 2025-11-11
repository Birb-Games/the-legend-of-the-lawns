extends Node2D

# Run this at the end of the day
func update_neighbors() -> void:
	for neighbor in $Neighbors.get_children():
		if neighbor is NeighborNPC:
			neighbor.update_cooldown()
