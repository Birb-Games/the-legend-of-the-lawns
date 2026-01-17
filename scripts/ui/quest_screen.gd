extends Control

var buttons: Array[Button] = []
var neighbor_paths: Array[NodePath] = []
var selected: int = -1
var show_alert: bool = true

func _ready() -> void:
	$InfoScreen.hide()
	$TemplateButton.hide()

func get_jobs() -> Array:
	var neighbors: Array = []
	var main: Main = $/root/Main
	for job: Job in main.job_list.values():
		var neighbor: NeighborNPC = get_node_or_null(job.neighbor_path)
		if neighbor == null:
			continue
		neighbors.push_back(neighbor)
	return neighbors

func select_button(index: int) -> void:
	if selected >= 0 and selected < buttons.size():
		buttons[selected].text = buttons[selected].text.substr(2)
	# Deselect the current neighbor if we clicked the same button
	if index == selected:
		selected = -1
		$/root/Main/Player/NeighborArrow.point_to = ""
		return
	# Set the new selected neighbor
	if index >= 0 and index < buttons.size():
		selected = index
		buttons[selected].text = " >" + buttons[selected].text
		$/root/Main/Player/NeighborArrow.point_to = neighbor_paths[selected]

func add_neighbor_buttons(
	parent: Node,
	neighbors: Array,
	button_texts: Array[String],
	start_index: int = 0,
) -> int:
	# Clear previous children
	for child in parent.get_children():
		child.queue_free()

	var spacing: ColorRect = ColorRect.new()
	spacing.color = Color8(0, 0, 0, 0)
	spacing.custom_minimum_size = Vector2(0.0, 2.0)
	parent.add_child(spacing)

	var index = start_index
	for neighbor: NeighborNPC in neighbors:
		var button: Button = $TemplateButton.duplicate()
		button.show()
		button.text = button_texts[index - start_index] 
		if selected == index:
			button.text = " >" + button.text
		button.custom_minimum_size.x = $InfoScreen/QuestBox.size.x - 24.0
		button.connect(
			"pressed",
			func():
				select_button(index)
		)
		parent.add_child(button)
		buttons.push_back(button)
		neighbor_paths.push_back(neighbor.get_path())
		index += 1
	
	parent.add_child(spacing.duplicate())
	return index

func get_job_button_text() -> Array[String]:
	var button_texts: Array[String] = []	
	var main: Main = $/root/Main
	for job: Job in main.job_list.values():
		var neighbor: NeighborNPC = get_node_or_null(job.neighbor_path)
		if neighbor == null:
			button_texts.push_back("")
			continue
		var text: String = " %s" % neighbor.display_name 
		if job.days_left == 1:
			text += " (1 day left!)"
		else:
			text += " (%d days left)" % job.days_left
		button_texts.push_back(text)
	return button_texts

func get_quest_button_text(neighbors: Array) -> Array[String]:
	var button_texts: Array[String] = []	
	for neighbor: NeighborNPC in neighbors:
		var text: String = " %s" % neighbor.display_name
		if neighbor.times_mowed > 0:
			text += " (DONE)"
		button_texts.push_back(text)
	return button_texts

func activate() -> void:
	show_alert = false
	$InfoScreen.show()
	$InfoScreen/QuestBox/StartGameLabel.hide()
	buttons.clear()
	neighbor_paths.clear()

	var main: Main = $/root/Main
	var button_texts: Array[String]
	# Create the list of lawns the player has previously mowed
	var jobs = get_jobs()
	$InfoScreen/QuestBox/JobLabel.visible = !jobs.is_empty()
	$InfoScreen/QuestBox/JobLawns.visible = !jobs.is_empty()
	button_texts = get_job_button_text()
	var index = add_neighbor_buttons($InfoScreen/QuestBox/JobLawns/List, jobs, button_texts)

	# Set up player stats
	$InfoScreen/Stats/StatsText.text = ""
	var player: Player = $/root/Main/Player 
	$InfoScreen/Stats/StatsText.text += "Name: %s\n" % main.player_name
	$InfoScreen/Stats/StatsText.text += "Money: $%d\n" % main.money
	$InfoScreen/Stats/StatsText.text += "Max Health: %d\n" % player.max_health

	var current_quest: Quest = Quest.get_quest(main.current_level)
	if current_quest == null:
		$InfoScreen/QuestBox/TODO.hide()
		$InfoScreen/QuestBox/Spacing.hide()
		$InfoScreen/QuestBox/RewardLabel.hide()
		$InfoScreen/QuestBox/Goals.hide()
		$InfoScreen/QuestBox/MowingGoal.hide()
		$InfoScreen/QuestBox/Lawns.hide()
		$InfoScreen/QuestBox/RewardLabel2.hide()
		return
	$InfoScreen/QuestBox/TODO.show()
	$InfoScreen/QuestBox/Spacing.show()
	$InfoScreen/QuestBox/RewardLabel.show()
	$InfoScreen/QuestBox/Goals.show()

	# Create the list of lawns that the player has to mow right now
	var current_neighbors = main.get_current_neighbors()
	$InfoScreen/QuestBox/MowingGoal.visible = !current_neighbors.is_empty()
	if Quest.completed_neighbors(current_neighbors):
		$InfoScreen/QuestBox/MowingGoal.text = " - Mow lawns: (DONE)"
	else:
		$InfoScreen/QuestBox/MowingGoal.text = " - Mow lawns:"
	$InfoScreen/QuestBox/Lawns.visible = !current_neighbors.is_empty()
	button_texts = get_quest_button_text(current_neighbors)
	add_neighbor_buttons($InfoScreen/QuestBox/Lawns/List, current_neighbors, button_texts, index)
	var button_sz: float = $TemplateButton.custom_minimum_size.y + 4.0
	var height: float = 12.0 + len(current_neighbors) * button_sz
	var max_height: float = 12.0 + 3.0 * button_sz
	$InfoScreen/QuestBox/Lawns.custom_minimum_size.y = min(height, max_height)

	# Add other quest goals
	for child in $InfoScreen/QuestBox/Goals.get_children():
		child.queue_free()
	for goal: Quest.Goal in current_quest.goals:
		var goal_label: Label = $InfoScreen/QuestBox/MowingGoal.duplicate()
		goal_label.show()
		goal_label.text = " - %s" % goal.description
		if goal.completed.call(main):
			goal_label.text += " (DONE)"
		$InfoScreen/QuestBox/Goals.add_child(goal_label)
	if current_quest.completed(main):
		var label: Label = $InfoScreen/QuestBox/MowingGoal.duplicate()
		label.text = "TO-DO list completed!"
		$InfoScreen/QuestBox/Goals.add_child(label)
		$InfoScreen/QuestBox/RewardLabel2.show()
		if main.current_level == 0:
			$InfoScreen/QuestBox/StartGameLabel.show()
	else:
		$InfoScreen/QuestBox/RewardLabel2.hide()

	# Set up reward button
	$InfoScreen/QuestBox/RewardLabel.text = "Reward: %s" % current_quest.reward.description
	if current_quest.reward.description.is_empty():
		$InfoScreen/QuestBox/RewardLabel.hide()
		$InfoScreen/QuestBox/RewardLabel2.hide()	

# Toggle the visibility of the screen
func toggle() -> void:
	if $InfoScreen.visible:
		$InfoScreen.hide()
	else:
		activate()

func _on_button_pressed() -> void:
	toggle()

func _process(_delta: float) -> void:
	var intro = get_node_or_null("/root/Main/HUD/Control/IntroWebsite")
	if intro or $/root/Main/HUD/MainMenu.visible:
		return

	var main: Main = $/root/Main
	if main.lawn_loaded or $/root/Main/HUD.npc_menu_open():
		hide()
		$InfoScreen.hide()
		return
	else:
		show()	

	if Input.is_action_just_pressed("toggle_quest_screen"):
		toggle()
	if Input.is_action_just_pressed("ui_cancel"):
		$InfoScreen.hide()
	
	if !visible:
		return

	$Alert.visible = show_alert

	var current_quest: Quest = Quest.get_quest(main.current_level)
	if current_quest and current_quest.completed(main):
		$Alert.show()

	if $InfoScreen.visible:
		$Alert.hide()

func reset() -> void:
	buttons.clear()
	neighbor_paths.clear()
	selected = -1
	show_alert = false
