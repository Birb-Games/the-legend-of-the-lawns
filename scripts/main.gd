extends Node2D

var lawns: Dictionary = {}
var lawnmower: RigidBody2D = preload("res://scenes/lawnmower.tscn").instantiate()
var neighborhood: Node2D = preload("res://scenes/neighborhood.tscn").instantiate()
@onready var player: CharacterBody2D = $Player
var current_lawn: Node2D

func _ready() -> void:
	lawns.set("BasicLawn", preload("res://scenes/basic_lawn.tscn").instantiate())
	lawns.set("FancyLawn", preload("res://scenes/fancy_lawn.tscn").instantiate())

func _process(_delta: float) -> void:
	update_hud()

	if Input.is_action_just_pressed("talk") and $Neighborhood/Villager1.player_in_area:
		load_field("BasicLawn")
	elif Input.is_action_just_pressed("talk") and $Neighborhood/Villager2.player_in_area:
		load_field("FancyLawn")

func load_field(lawn_name: String) -> void:
	if lawnmower.is_inside_tree():
		printerr("Loading field without unloading previous!")
	
	remove_child(neighborhood)
	add_child(lawnmower)
	lawnmower.position = Vector2.ZERO
	current_lawn = lawns.get(lawn_name)
	add_child(current_lawn)
	player.position = Vector2.ZERO

func return_to_neighborhood() -> void:
	if !lawnmower.is_inside_tree():
		printerr("Loading neighborhood not from field!")
	
	add_child(neighborhood)
	remove_child(lawnmower)
	remove_child(current_lawn)
	player.position = Vector2.ZERO

func update_hud():
	if $Player.in_lawnmower_range() and $Lawnmower.is_stuck():
		$HUD.update_info_text("Lawn mower is stuck!")
	else:
		$HUD.update_info_text("")
	
	$HUD.update_progress_bar($Lawn.get_perc_cut())
