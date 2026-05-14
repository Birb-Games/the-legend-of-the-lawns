extends CanvasLayer

@export var progress_bar_gradient: Gradient
@export var final_credits_scene: PackedScene

var time_elapsed: float = 0.0

func _ready() -> void:
	$Control/InfoText.text = ""

func activate_finish_screen() -> void:
	$Control/Finishscreen.activate()

# Returns if the fail screen was activated
func activate_fail_screen() -> bool:
	var player = $/root/Main/Player
	if player.health > 0:
		return false
	
	$Control/DamageFlash.hide()
	$Control/Failscreen.activate()
	return true

func _process(_delta: float) -> void:
	if $MainMenu.visible:
		get_tree().paused = true
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		$Control.hide()
		return
	
	$Control.show()

	# Toggle the mouse cursor
	if get_tree().paused:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CONFINED
	
	if $Control/Finishscreen.visible or $Control/Failscreen.visible:
		return

	if get_node_or_null("Control/FinalCredits"):
		return
	
	if activate_fail_screen():
		return

	var intro = get_node_or_null("Control/IntroWebsite")
	if intro:
		return
	
	# Open pause menu
	if Input.is_action_just_pressed("ui_cancel"):
		$Control/TransitionRect.end_transition()
		if npc_menu_open() and npc_menu_buttons_visible():
			# Exit out of neighbor menu
			$Control/NPCMenu.hide()
			$Control/NPCMenu.hide_neighbor()
		elif quest_screen_open():
			$Control/QuestScreen/InfoScreen.hide()
		else:
			toggle_pause_menu()

# used for pop up messages to provide information to the player
func update_info_text(text: String) -> void:
	$Control/InfoText.text = text

func toggle_pause_menu() -> void:
	$Control/PauseMenu.visible = !$Control/PauseMenu.visible
	# Show buttons that appear only on the lawn
	if $Control/PauseMenu.visible:
		$Control/PauseMenu/Label.visible = $/root/Main.lawn_loaded
		$Control/PauseMenu/HBoxContainer.visible = $/root/Main.lawn_loaded
		$Control/PauseMenu/Note.visible = !$/root/Main.lawn_loaded
		$Control/PauseMenu/MainMenu.visible = !$/root/Main.lawn_loaded
	get_tree().paused = $Control/PauseMenu.visible

# updates progress bar based on the given percent (0.0 to 1.0)
func update_progress_bar(lawn: Lawn) -> void:
	# used for the neighborhood
	if lawn == null:
		$Control/ProgressBar.hide()
		return

	var percent: float = lawn.get_perc_cut()
	$Control/ProgressBar.show()
	$Control/ProgressBar.size.x = percent * $Control/ProgressBar/ProgressBackground.size.x
	$Control/ProgressBar.color = progress_bar_gradient.sample(percent)
	if percent < 1.0:
		$Control/ProgressBar/ProgressBarPercent.text = "Lawn Mowed: %d%%" % int(percent * 100)
	elif lawn.weeds_killed < lawn.total_weeds:
		$Control/ProgressBar/ProgressBarPercent.text = "Kill Weeds: %d/%d" % [ lawn.weeds_killed, lawn.total_weeds ]
	elif lawn.nests_destroyed < lawn.nest_count:
		$Control/ProgressBar/ProgressBarPercent.text = "Destroy Nests: %d/%d" % [ lawn.nests_destroyed, lawn.nest_count ]
	elif lawn.bosses_killed < lawn.boss_count:
		$Control/ProgressBar/ProgressBarPercent.text = "Defeat Enemies: %d/%d" % [ lawn.bosses_killed, lawn.boss_count ]
	else:
		$Control/ProgressBar/ProgressBarPercent.text = "Lawn Mowed: 100%"

# Similar as update_progress_bar but with the health bar
func update_health_bar(health: int, max_health: int) -> void:
	if max_health == 0 or health == 0:
		$Control/HealthBar.hide()
		return
	
	$Control/HealthBar.show()
	var percent: float = float(health) / float(max_health)
	$Control/HealthBar.size.x = percent * $Control/HealthBar/HealthBackground.size.x
	$Control/HealthBar/HealthPercent.text = "HP: %d/%d" % [health, max_health]

# Stamina is given on a 0.0 -> 1.0 scale
func update_stamina_bar(stamina: float) -> void:
	if stamina < 0.0 or stamina >= 1.0:
		$Control/StaminaBar.hide()
		return
	$Control/StaminaBar.show()
	$Control/StaminaBar.size.x = stamina * $Control/StaminaBar/StaminaBackground.size.x

func update_timer(delta: float) -> void:
	$Control/Timer.show()
	$Control/Bonus.show()
	$Control/Timer.text = num_as_time_string(time_elapsed)
	var time_limit_str = num_as_time_string($/root/Main/Lawn.time_limit)
	$Control/Bonus.text = "BONUS: %s" % time_limit_str
	time_elapsed += delta

func hide_timer() -> void:
	time_elapsed = 0.0
	$Control/Timer.hide()
	$Control/Bonus.hide()

func hide_neighborhood_hud() -> void:
	$Control/DayLabel.hide()
	$Control/MoneyLabel.hide()
	$Control/LawnCounter.hide()

func update_day_counter(days: int) -> void:
	$Control/DayLabel.show()
	$Control/DayLabel.text = "Day %d" % days

func update_money_counter(player_name: String, money: int) -> void:
	$Control/MoneyLabel.show()
	var formatted_name = player_name
	if player_name.length() > 12:
		formatted_name = player_name.substr(0, 12) + "..."
	$Control/MoneyLabel.text = "%s $%d" % [ formatted_name, money ]

func update_lawn_counter(lawns_mowed: int) -> void:
	$Control/LawnCounter.show()
	var text: String
	if lawns_mowed == 1:
		text = "Mowed 1 Lawn"
	else:
		text = "Mowed %d Lawns" % lawns_mowed
	
	$Control/LawnCounter.text = text

func set_neighbor_menu(neighbor: NeighborNPC) -> void:
	$Control/NPCMenu.set_menu(neighbor)

func set_npc_menu(npc: NPC) -> void:
	$Control/NPCMenu.set_npc_menu(npc)

func set_bus_menu(bus_stop: BusStop) -> void:
	$Control/NPCMenu.set_bus_menu(bus_stop)

func set_job_board_menu(job_board: JobBoard) -> void:
	$Control/NPCMenu.set_job_board_menu(job_board)

func set_skip_day_menu() -> void:
	$Control/NPCMenu.set_skip_day_menu()

func set_buy_menu(item: Buy) -> void:
	$Control/NPCMenu.set_buy_menu(item)

func hide_neighbor_menu() -> void:
	$Control/NPCMenu.hide()

func alert(title: String, description: String, button_text: String, can_move: bool = false) -> void:
	$Control/NPCMenu.alert(title, description, button_text)
	$Control/NPCMenu.player_can_move = can_move

func update_damage_flash(perc: float) -> void:
	if perc <= 0.0:
		$Control/DamageFlash.hide()
		return
	$Control/DamageFlash.show()
	var alpha = int(perc * 128.0)
	$Control/DamageFlash.color = Color8(255, 0, 0, alpha)

func get_current_neighbor() -> NeighborNPC:
	return $Control/NPCMenu.current_neighbor

# Formats a number in seconds as a time string in the format "MM:SS"
func num_as_time_string(num: float) -> String:
	var t = floori(num)
	var minutes: int = int(floori(t / 60.0))
	var seconds: int = int(t % 60)
	return "%02d:%02d" % [minutes, seconds]

func npc_menu_open() -> bool:
	return $Control/NPCMenu.visible

func npc_menu_buttons_visible() -> bool:
	for button in $Control/NPCMenu.buttons:
		if button.visible:
			return true
	return false

func npc_menu_can_move() -> bool:
	return $Control/NPCMenu.player_can_move

func quest_screen_open() -> bool:
	return $Control/QuestScreen/InfoScreen.visible

func cheat_console_open() -> bool:
	var cheat_console = get_node_or_null("Control/CheatConsole")
	if cheat_console == null:
		return false
	return cheat_console.visible

func reset() -> void:
	$Control/InventoryGUI.reset()

func add_final_credits() -> void:
	if get_node_or_null("Control/FinalCredits"):
		return
	$Control.add_child(final_credits_scene.instantiate())
