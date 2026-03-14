extends Node2D

class_name Neighborhood

func update_neighbors() -> void:
	for neighbor: NeighborNPC in $Neighbors.get_children():
		neighbor.cooldown -= 1
		neighbor.cooldown = max(neighbor.cooldown, 0)
		neighbor.player_in_area = false

func save() -> Array:
	var data = []

	for child in $NPCs.get_children():
		if child is NPC:
			data.push_back(child.save())

	for child in $Neighbors.get_children():
		if child is NeighborNPC:
			data.push_back(child.save())

	return data
