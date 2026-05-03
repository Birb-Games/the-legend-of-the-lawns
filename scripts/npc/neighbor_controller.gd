extends Node2D

@onready var neighbor: NeighborNPC = get_parent()
@export var required_npcs: Array[NPC]
@export var required_neighbors: Array[NeighborNPC]
@export var disable_after_first_time: bool = false

func available() -> bool:
	if disable_after_first_time and neighbor.times_mowed > 0:
		return false

	for npc: NPC in required_npcs:
		if npc.first_time:
			return false
	
	for required_neighbor: NeighborNPC in required_neighbors:
		if required_neighbor.times_mowed <= 0:
			return false
	
	return true

func _process(_delta: float) -> void:
	neighbor.disabled = !available()
	neighbor.visible = available()
