class_name Job

var days_left: int = 0
var neighbor_path: NodePath

func _init(days: int = 0, neighbor: NeighborNPC = null) -> void:
	days_left = days
	if neighbor:
		neighbor_path = neighbor.get_path()

func update() -> void:
	days_left -= 1

func get_message(neighbor: NeighborNPC) -> String:
	if neighbor == null:
		return ""
	return """I would like to hire someone to mow my lawn.
Please complete within <%d> days.
- %s""" % [days_left, neighbor.display_name]

func to_json_str(key: String) -> String:
	var data: Dictionary = {
		"key" : key,
		"days_left" : days_left,
		"neighbor_path" : neighbor_path
	}
	return JSON.stringify(data)

# Returns null if a job can not be generated
static func generate_job(current_jobs: Dictionary, neighbors: Array) -> Job:
	var filtered: Array = []
	for neighbor: NeighborNPC in neighbors:
		if neighbor.name in current_jobs:
			continue
		if neighbor.cooldown > 0:
			continue
		filtered.push_back(neighbor)
	if filtered.is_empty():
		return null
	var rand_neighbor: NeighborNPC = filtered[randi() % len(filtered)]
	return Job.new(randi_range(2, 5), rand_neighbor)

static func parse_job_list(s: String) -> Dictionary:
	var json_list: PackedStringArray = s.split("|")
	var list: Dictionary = {}
	for json_str in json_list:
		if json_str.is_empty():
			continue
		var parsed = JSON.new()
		var parse_result = parsed.parse(json_str)
		if parse_result != OK:
			printerr("Error while loading job list.")
			printerr("JSON parse error: %s." % parsed.get_error_message())
			continue
		var key: String = Save.get_val(parsed.data, "key")
		if key == null:
			continue
		var path: NodePath = Save.get_val(parsed.data, "neighbor_path")
		if path == null:
			continue
		var days = Save.get_val(parsed.data, "days_left", 0)
		if days <= 0:
			continue
		var job = Job.new(days)
		job.neighbor_path = path
		list[key] = job
	return list
