extends CanvasLayer

@export var progress_bar_gradient: Gradient

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
	# Toggle the mouse cursor
	if get_tree().paused:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CONFINED
	
	if $Control/Finishscreen.visible or $Control/Failscreen.visible:
		return
	
	if activate_fail_screen():
		return
	
	# Open pause menu for lawn
	if Input.is_action_just_pressed("ui_cancel"):
		if $Control/NPCMenu.visible:
			# Exit out of neighbor menu
			$Control/NPCMenu.hide()
			$Control/NPCMenu.hide_neighbor()
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
	get_tree().paused = $Control/PauseMenu.visible

# updates progress bar based on the given percent (0.0 to 1.0)
func update_progress_bar(percent: float, weeds_killed: int, total_weeds: int) -> void:
	# used for the neighborhood
	if percent < 0.0:
		$Control/ProgressBar.hide()
		return

	$Control/ProgressBar.show()
	$Control/ProgressBar.size.x = percent * $Control/ProgressBar/ProgressBackground.size.x
	$Control/ProgressBar.color = progress_bar_gradient.sample(percent)
	if percent < 1.0:
		$Control/ProgressBar/ProgressBarPercent.text = "Lawn Mowed: %d%%" % int(percent * 100)
	else:
		$Control/ProgressBar/ProgressBarPercent.text = "Kill Weeds: %d/%d" % [ weeds_killed, total_weeds ]

# Similar as update_progress_bar but with the health bar
func update_health_bar(health: int, max_health: int) -> void:
	if max_health == 0 or health == 0:
		$Control/HealthBar.hide()
		return
	
	$Control/HealthBar.show()
	var percent: float = float(health) / float(max_health)
	$Control/HealthBar.size.x = percent * $Control/HealthBar/HealthBackground.size.x
	$Control/HealthBar/HealthPercent.text = "HP: %d/%d" % [health, max_health] 

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

func update_money_counter(money: int) -> void:
	$Control/MoneyLabel.show()
	$Control/MoneyLabel.text = "$%d" % money

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

func set_skip_day_menu() -> void:
	$Control/NPCMenu.set_skip_day_menu()

func hide_neighbor_menu() -> void:
	$Control/NPCMenu.hide_menu()

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
