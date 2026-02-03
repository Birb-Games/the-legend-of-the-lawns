class_name Main

extends Node2D

@onready var neighborhood_scene: PackedScene = preload("uid://8t3kf3315lkx")
@onready var neighborhood: Neighborhood = $Neighborhood
@onready var player: Player = $Player
@onready var player_pos: Vector2 = $Player.position
var lawn_loaded: bool = false

var player_name: String = ""
var save_path: String = ""
var continue_save: String = ""

# How much money the player currently has
var money: int = 0
# What day it currently is
var current_day: int = 1
# How many lawns the player mowed
var lawns_mowed: int = 0
var current_wage: int = 0
var current_level: int = 0
# Key: node path, Value: Job info 
var job_list: Dictionary = {}

# Update the money based on the current wage and the modifier (penalties and bonuses)
func update_money(modifier: int) -> void:
	money += max(current_wage + modifier, 0)

func _ready() -> void:
	Settings.load()
	Settings.apply_settings()

	# Keep cursor in window - this is to prevent the mouse cursor from accidentally
	# leaving when shooting enemies
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED

	# Create the save directory
	if !DirAccess.dir_exists_absolute("user://saves"):
		var dir = DirAccess.open("user://")
		if dir:
			dir.make_dir("saves")
			print("Created save dir!")
		else:
			printerr("Failed to create save directory!")
	
	var file = FileAccess.open("user://continue", FileAccess.READ)
	if file != null:
		continue_save = file.get_line()

func _process(delta: float) -> void:
	update_hud(delta)
		
	# Reenable camera position smoothing if it was disabled
	if !$Player/Camera2D.position_smoothing_enabled:
		$Player/Camera2D.position_smoothing_enabled = true
	
	# Hide player lawn mower & water gun if we are in the neighborhood
	if neighborhood.is_inside_tree():
		$Player/Lawnmower.hide()
		$Player/WaterGun.hide()

func advance_day() -> void:
	current_day += 1
	$HUD/Control/TransitionRect.start_animation()
	for key: String in job_list.keys():
		var job: Job = job_list[key]
		job.update()
	for key: String in job_list.keys():
		var job: Job = job_list[key]
		if job.days_left <= 0:
			job_list.erase(key)
	$HUD/Control/QuestScreen.show_alert = false
	Buy.update_buy_list()

func load_lawn(lawn_template: PackedScene, difficulty_level: int) -> void:
	player.reset_health()
	player.status_effects.clear()
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED
	# Unload neighborhood
	remove_child(neighborhood)
	# Load lawn
	var lawn: Lawn = lawn_template.instantiate()
	lawn.difficulty += difficulty_level
	lawn.difficulty = clamp(lawn.difficulty, 0, 8)
	lawn.name = "Lawn"
	add_child(lawn)	
	# Set player position and direction
	player.position = lawn.get_spawn()
	player.dir = "down"
	$Player/Camera2D.zoom = Vector2(8.0, 8.0)
	$HUD/Control/TransitionRect.start_bus_animation()
	lawn.update_enemy_pathfinding()
	# Set lawn loaded flag
	lawn_loaded = true
	# Disable camera position smoothing for a frame so that we do not have any 
	# strange sudden camera movements when we are going into a lawn
	$Player/Camera2D.position_smoothing_enabled = false

func return_to_neighborhood() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED
	player.reset_health()
	player.status_effects.clear()
	if get_node_or_null("Lawn"):
		get_node("Lawn").queue_free()
	if !neighborhood.is_inside_tree():
		add_child(neighborhood)
	$Neighborhood/JobBoard.update()
	$Player/Lawnmower.hide()
	$Player/WaterGun.hide()
	$Player/NeighborArrow.point_to = ""
	player.position = player_pos
	current_wage = 0
	player.dir = "down"
	$Player.fire_timer = 0.0
	lawn_loaded = false
	# Disable camera position smoothing for a frame so that we do not have any 
	# strange sudden camera movements when we are returning to the neighborhood
	$Player/Camera2D.position_smoothing_enabled = false

func update_hud_lawn(delta: float) -> void:
	$HUD/Control/InfoText.visible = player.health > 0
	$HUD.update_info_text("")
	if $Player/WaterGun.visible and $Player.can_pick_up_lawnmower:
		$HUD.update_info_text("You can not move the lawn mower while holding a water gun.")
	elif $Player/Lawnmower.visible:
		if $Player.too_close_to_drop_mower():
			$HUD.update_info_text("You are standing too close to something to release the mower.")
		else:
			$HUD.update_info_text("Press [SPACE] to let go of the lawn mower.")
	elif $Player.can_pick_up_lawnmower and $Lawn/Lawnmower.visible:
		if $Player/PickupCollisionChecker.colliding():
			$HUD.update_info_text("You are standing too close to something to start mowing.")
		else:
			$HUD.update_info_text("Press [SPACE] to begin mowing!")
	elif $Player/WaterGun.visible:
		$HUD.update_info_text("Press [SPACE] to drop water gun.")
	elif $Player.can_pick_up_water_gun:
		$HUD.update_info_text("Press [SPACE] to pick up water gun.")
	
	if $Player.health > 0:
		$HUD.update_progress_bar($Lawn.get_perc_cut(), $Lawn.weeds_killed, $Lawn.total_weeds)
	else:
		$HUD/Control/ProgressBar.hide()
	$HUD.update_health_bar($Player.health, $Player.get_max_health())
	$HUD.update_timer(delta)

func update_hud_neighborhood() -> void:
	$HUD.update_info_text($Player.interact_text)
	# hide info text if talking to a neighbor
	$HUD/Control/InfoText.visible = !$HUD.npc_menu_open() and !$HUD.quest_screen_open()
	
	$HUD.update_progress_bar(-1.0, 0, 0) # -1.0 hides the progress bar
	$HUD.update_health_bar(0, 0)
	$HUD.hide_timer()

func update_hud(delta: float) -> void:
	if lawn_loaded:
		update_hud_lawn(delta)
	else:
		update_hud_neighborhood()

	if lawn_loaded:
		$HUD.hide_neighborhood_hud()
	elif !lawn_loaded and $HUD.quest_screen_open():
		$HUD.hide_neighborhood_hud()
	else:
		$HUD.update_day_counter(current_day)
		$HUD.update_money_counter(player_name, money)
		$HUD.update_lawn_counter(lawns_mowed)
	if player.health > 0:
		if player.fire_timer > 0.0:
			$HUD.update_damage_flash(1.0)
		else:
			$HUD.update_damage_flash(player.get_damage_timer_perc())
	else:
		# Hide the damage flash when the player lost all health to avoid
		# having it cover up the fail screen
		$HUD.update_damage_flash(-1.0)

func reset() -> void:
	# Reset neighborhood
	neighborhood = null
	$Neighborhood.free()
	Buy.buy_item_list.clear()
	add_child(neighborhood_scene.instantiate())
	neighborhood = $Neighborhood
	job_list.clear()

	return_to_neighborhood()
	money = 0
	current_day = 1
	lawns_mowed = 0
	current_level = 0
	player.reset()
	$/root/Main/HUD/Control/QuestScreen.reset()
	$Neighborhood/JobBoard.update()

func save() -> Dictionary:
	return {
		"money" : money,
		"current_day" : current_day,
		"lawns_mowed": lawns_mowed,
		"player_name" : player_name,
		"current_level" : current_level,
		"jobs" : get_job_list_str()
	}

func save_progress() -> void:
	print("Attempting to save progress to: ", save_path)
	var save_file = FileAccess.open(save_path, FileAccess.WRITE)
	
	if !save_file:
		printerr("Error: could not save, can not open: ", save_path)
		return

	# Store the main data
	var main_json = JSON.stringify(save())
	save_file.store_line(main_json)

	# Store the player data
	var player_json = JSON.stringify(player.save())
	save_file.store_line(player_json)

	# Store the neighborhood data
	var neighborhood_data = neighborhood.save()
	for data in neighborhood_data:
		var json = JSON.stringify(data)
		save_file.store_line(json)

func get_job_list_str() -> String:
	var job_list_str: String = ""
	for key: String in job_list.keys():
		var job: Job = job_list[key]
		job_list_str += "%s|" % job.to_json_str(key)
	return job_list_str

func load_save() -> bool:
	var save_file = FileAccess.open(save_path, FileAccess.READ)

	if !save_file:
		printerr("Error: could not load save, can not open: ", save_path)
		return false

	# Load the first line (player name, money, current day, etc.)
	var line = save_file.get_line()
	var json = JSON.new()
	var parse_result = json.parse(line)
	if parse_result != OK:
		printerr("Error loading:")
		printerr("JSON parse error: ", json.get_error_message(), " in ", save_path)
		return false	
	var data = json.data
	player_name = Save.get_val(data, "player_name", "Billy")
	money = max(Save.get_val(data, "money", 0), 0)
	current_day = max(Save.get_val(data, "current_day", 1), 1)
	$HUD/Control/QuestScreen.show_alert = (current_day == 1)
	lawns_mowed = max(Save.get_val(data, "lawns_mowed", 0), 0)
	current_level = max(Save.get_val(data, "current_level", 0), 0)
	job_list = Job.parse_job_list(Save.get_val(data, "jobs", ""))

	# Load player stats
	line = save_file.get_line()
	json = JSON.new()
	parse_result = json.parse(line)
	# Set the player defaults
	player.reset()
	if parse_result != OK:
		printerr("Error loading player:")
		printerr("JSON parse error: ", json.get_error_message(), " in ", save_path)
	else:
		data = json.data
		player.max_health_level = max(Save.get_val(data, "max_health_level", 0), 0)
	
	if current_day == 1:
		player.global_position = $/root/Main/Neighborhood/Intro/PlayerStart.global_position

	# Load neighborhood
	line = save_file.get_line()
	while !line.is_empty():
		json = JSON.new()
		parse_result = json.parse(line)
		if parse_result != OK:
			printerr("JSON parse error: ", json.get_error_message(), " in ", save_path)
		elif "path" in json.data:
			var path = json.data["path"]
			print("Loaded ", path)
			var node = get_node_or_null(path)
			if node != null and node.has_method("load_from"):
				node.load_from(json.data)
		line = save_file.get_line()
	
	update_continue_save()
	$Neighborhood/JobBoard.update()
	Buy.update_buy_list()
	return true

func update_continue_save() -> void:
	continue_save = save_path
	# Save the current save
	var file = FileAccess.open("user://continue", FileAccess.WRITE)
	if file != null:
		file.store_line(continue_save)

func advance_quest() -> void:
	var current_quest: Quest = Quest.get_quest(current_level)
	if current_quest == null:
		return
	current_quest.reward.give.call(self)
	current_level += 1
	$HUD/Control/QuestScreen.selected = -1
	$Player/NeighborArrow.point_to = ""

func get_current_neighbors() -> Array:
	var neighbors: Array = []
	for neighbor in $Neighborhood/Neighbors.get_children():
		if neighbor is NeighborNPC:
			if neighbor.disabled:
				continue
			if neighbor.level == current_level:
				neighbors.push_back(neighbor)
	return neighbors

func play_sfx(id: String, check_if_playing: bool = false):
	var sfx = get_node_or_null("Sfx/%s" % id)
	if sfx == null:
		return
	if sfx is AudioStreamPlayer:
		if sfx.playing and check_if_playing:
			return
		sfx.play()
