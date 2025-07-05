extends CanvasLayer

@export var progress_bar_gradient: Gradient

func _ready() -> void:
	$Control/InfoText.text = ""

func activate_finish_screen():
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
		if $Control/NeighborMenu.visible:
			# Exit out of neighbor menu
			$Control/NeighborMenu.hide()
			$Control/NeighborMenu.hide_neighbor()
		else:
			toggle_pause_menu()

# used for pop up messages to provide information to the player
func update_info_text(text: String) -> void:
	$Control/InfoText.text = text

func toggle_pause_menu():
	$Control/PauseMenu.visible = !$Control/PauseMenu.visible
	# Show buttons that appear only on the lawn
	if $Control/PauseMenu.visible:
		$Control/PauseMenu/Label.visible = $/root/Main.lawn_loaded
		$Control/PauseMenu/HBoxContainer.visible = $/root/Main.lawn_loaded
	get_tree().paused = $Control/PauseMenu.visible

# updates progress bar based on the given percent (0.0 to 1.0)
func update_progress_bar(percent: float) -> void:
	# used for the neighborhood
	if percent < 0.0:
		$Control/ProgressBar.hide()
		return

	$Control/ProgressBar.show()
	$Control/ProgressBar.size.x = percent * $Control/ProgressBar/ProgressBackground.size.x
	$Control/ProgressBar.color = progress_bar_gradient.sample(percent)
	$Control/ProgressBar/ProgressBarPercent.text = str(int(percent * 100)) + "%"

# Similar as update_progress_bar but with the health bar
func update_health_bar(percent: float) -> void:
	if percent < 0.0:
		$Control/HealthBar.hide()
		return
	
	$Control/HealthBar.show()
	$Control/HealthBar.size.x = percent * $Control/HealthBar/HealthBackground.size.x
	$Control/HealthBar/HealthPercent.text = str(int(percent * 100)) + "%"

func update_day_counter(days: int):
	$Control/DayLabel.text = "Day %d" % days

func update_money_counter(money: int):
	$Control/MoneyLabel.text = "$%d" % money

func set_neighbor_menu(neighbor: NeighborNPC) -> void:
	$Control/NeighborMenu.set_menu(neighbor)

func set_npc_menu(npc: NPC) -> void:
	$Control/NeighborMenu.set_npc_menu(npc)

func hide_neighbor_menu() -> void:
	$Control/NeighborMenu.hide_menu()

func update_damage_flash(perc: float) -> void:
	if perc <= 0.0:
		$Control/DamageFlash.hide()
		return
	$Control/DamageFlash.show()
	var alpha = int(perc * 128.0)
	$Control/DamageFlash.color = Color8(255, 0, 0, alpha)

func get_current_neighbor() -> NeighborNPC:
	return $Control/NeighborMenu.current_neighbor
