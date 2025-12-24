extends Node2D

# Run this at the end of the day
func update_neighbors() -> void:
	for neighbor in $Neighbors.get_children():
		if neighbor is NeighborNPC:
			neighbor.update_cooldown()

func save() -> Array:
	var data = []

	for child in $NPCs.get_children():
		if child is NPC:
			data.push_back(child.save())

	for child in $Neighbors.get_children():
		if child is NeighborNPC:
			data.push_back(child.save())

	return data
