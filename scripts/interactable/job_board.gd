extends Area2D

class_name JobBoard

var player_in_area: bool = false
var current_job: Job = null

func get_neighbors(main: Main) -> Array:
	var neighbors: Array = []
	for child: NeighborNPC in main.neighborhood.get_node("Neighbors").get_children():
		if child.disabled:
			continue
		if child.times_mowed > 0:
			neighbors.push_back(child)
	return neighbors

func generate_job() -> void:
	var main: Main = $/root/Main
	var neighbors: Array = get_neighbors(main)
	current_job = Job.generate_job(main.job_list, neighbors)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("interact") and player_in_area:
		$/root/Main/HUD.set_job_board_menu(self)

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		body.interact_text = "Job board - [SPACE]"
		player_in_area = true

func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		body.interact_text = ""
		player_in_area = false
