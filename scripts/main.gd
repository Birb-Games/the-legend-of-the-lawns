extends Node2D

var lawnmower: RigidBody2D = preload("res://scenes/lawnmower.tscn").instantiate()
var neighborhood: Node2D = preload("res://scenes/neighborhood.tscn").instantiate()

# A dictionary of dictionaries containing the descriptions of lawns, the lawns themselves, and the nodes for each neighbor.
@onready var neighbors: Dictionary = {
	"Villager1": {"description": "A very boring lawn.", "lawn": preload("res://scenes/basic_lawn.tscn").instantiate(), "node": $Neighborhood/Villager1},
	"Villager2": {"description": "A very fancy lawn!", "lawn": preload("res://scenes/fancy_lawn.tscn").instantiate(), "node": $Neighborhood/Villager2}
}

@onready var player: CharacterBody2D = $Player
var current_lawn: Node2D #used for loading and unloading the selected lawn
var lawn_loaded: bool = false

func _process(_delta: float) -> void:
	update_hud()

	if Input.is_action_just_pressed("talk"):
		for neighbor_name in neighbors.keys():
			if neighbors.get(neighbor_name).get("node").player_in_area:
				talk_to_neighbor(neighbor_name)
	
	#debug for returning to neighborhood
	if Input.is_action_just_pressed("ui_cancel"):
		if lawn_loaded:
			return_to_neighborhood()

func talk_to_neighbor(neighbor_name: String) -> void:
	if lawn_loaded:
		printerr("Talking to neighbor while in lawn!")
	
	current_lawn = neighbors.get(neighbor_name).get("lawn")
	$HUD.set_neighbor_menu(neighbor_name, neighbors.get(neighbor_name).get("description"))

func load_current_lawn() -> void:
	if current_lawn == null:
		printerr("No lawn selected!")
	
	remove_child(neighborhood)
	add_child(lawnmower)
	lawnmower.position = Vector2.ZERO
	add_child(current_lawn)
	player.position = Vector2.ZERO
	lawn_loaded = true

func return_to_neighborhood() -> void:
	if !lawn_loaded:
		printerr("Loading neighborhood from neighborhood!")
	
	add_child(neighborhood)
	remove_child(lawnmower)
	remove_child(current_lawn)
	current_lawn = null
	player.position = Vector2.ZERO
	lawn_loaded = false

func update_hud():
	if lawn_loaded:
		if $Player.in_lawnmower_range() and $Lawnmower.is_stuck():
			$HUD.update_info_text("Lawn mower is stuck!")
		else:
			$HUD.update_info_text("")
		
		$HUD.update_progress_bar($Lawn.get_perc_cut())
	else: 
		$HUD.update_progress_bar(-1.0) # -1.0 hides the progress bar

func _on_leave_button_pressed() -> void:
	$HUD.hide_neighbor_menu()

func _on_accept_button_pressed() -> void:
	$HUD.hide_neighbor_menu()
	load_current_lawn()
