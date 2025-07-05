class_name Main

extends Node2D

@onready var neighborhood: Node2D = $Neighborhood
@onready var player: CharacterBody2D = $Player
@onready var player_pos: Vector2 = $Player.position
var lawn_loaded: bool = false

# How much money the player currently has
var money: int = 0
# What day it currently is
# Should be used for determining difficulty as well
var current_day: int = 1
var current_wage: int = 0

func update_wage() -> void:
	money += current_wage

func _ready() -> void:
	# Keep cursor in window - this is to prevent the mouse cursor from accidentally
	# leaving when shooting enemies
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED

func _process(_delta: float) -> void:
	update_hud()

func advance_day():
	neighborhood.update_neighbors()
	current_day += 1

func load_lawn(lawn_template: PackedScene) -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED
	# Unload neighborhood
	remove_child(neighborhood)
	# Load lawn
	var lawn = lawn_template.instantiate()
	lawn.name = "Lawn"
	add_child(lawn)
	# Set player position and direction
	player.position = lawn.get_spawn()
	player.dir = "down"
	# Set lawn loaded flag
	lawn_loaded = true

func return_to_neighborhood() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED
	player.reset_health()
	if get_node("Lawn"):
		get_node("Lawn").queue_free()
	if !neighborhood.is_inside_tree():
		add_child(neighborhood)
	$Player/WaterGun.hide()
	player.position = player_pos
	current_wage = 0
	player.dir = "down"
	lawn_loaded = false

func update_hud_lawn():
	$HUD/Control/InfoText.show()
	$HUD.update_info_text("")
	if $Player/WaterGun.visible and $Player.in_lawnmower_range():
		$HUD.update_info_text("You can not move the lawn mower while holding a water gun.")
	elif $Player/WaterGun.visible:
		$HUD.update_info_text("Press [SPACE] to drop water gun.")
	elif $Player.in_lawnmower_range() and $Lawn/Lawnmower.is_stuck():
		$HUD.update_info_text("Lawn mower is stuck!")
	elif $Player.can_pick_up_water_gun:
		$HUD.update_info_text("Press [SPACE] to pick up water gun.")
	
	$HUD.update_progress_bar($Lawn.get_perc_cut())
	$HUD.update_health_bar($Player.get_hp_perc())

func update_hud_neighborhood():
	$HUD.update_info_text($Player.interact_text)	
	# hide info text if talking to a neighbor
	$HUD/Control/InfoText.visible = !$HUD/Control/NeighborMenu.visible
	
	$HUD.update_progress_bar(-1.0) # -1.0 hides the progress bar
	$HUD.update_health_bar(-1.0)

func update_hud():
	if lawn_loaded:
		update_hud_lawn()
	else:
		update_hud_neighborhood()
	
	$HUD.update_day_counter(current_day)
	$HUD.update_money_counter(money)
	if player.health > 0:
		$HUD.update_damage_flash(player.get_damage_timer_perc())
	else:
		# Hide the damage flash when the player lost all health to avoid
		# having it cover up the fail screen
		$HUD.update_damage_flash(-1.0)
