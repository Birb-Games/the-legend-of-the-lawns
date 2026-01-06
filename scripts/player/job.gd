class_name Job

var days_left: int = 0
var neighbor_path: NodePath

func _init(days: int, neighbor: NeighborNPC) -> void:
	days_left = days
	neighbor_path = neighbor.get_path()

func update() -> void:
	days_left -= 1

func get_message(neighbor: NeighborNPC) -> String:
	if neighbor == null:
		return ""
	return """I would like to hire someone to mow my lawn.
Please complete within <%d> days.
- %s""" % [days_left, neighbor.display_name]

# Returns null if a job can not be generated
static func generate_job(current_jobs: Dictionary, neighbors: Array) -> Job:
	var filtered: Array = []
	for neighbor: NeighborNPC in neighbors:
		if neighbor.name in current_jobs:
			continue
		filtered.push_back(neighbor)
	if filtered.is_empty():
		return null
	var rand_neighbor: NeighborNPC = filtered[randi() % len(filtered)]
	return Job.new(randi_range(2, 5), rand_neighbor)
