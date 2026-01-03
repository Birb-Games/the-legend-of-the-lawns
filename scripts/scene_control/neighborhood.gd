extends Node2D

func save() -> Array:
	var data = []

	for child in $NPCs.get_children():
		if child is NPC:
			data.push_back(child.save())

	for child in $Neighbors.get_children():
		if child is NeighborNPC:
			data.push_back(child.save())

	return data
