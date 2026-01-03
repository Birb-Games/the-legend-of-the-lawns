extends Control

var buttons: Array[Button] = []
var neighbor_paths: Array[NodePath] = []
var selected: int = -1

func _ready() -> void:
	$InfoScreen.hide()
	$TemplateButton.hide()

func get_current_neighbors() -> Array:
	var neighbors: Array = []
	var main: Main = $/root/Main
	for neighbor in $/root/Main/Neighborhood/Neighbors.get_children():
		if neighbor is NeighborNPC:
			if neighbor.disabled:
				continue
			if neighbor.level == main.current_level:
				neighbors.push_back(neighbor)
	return neighbors

func get_prev_neighbors() -> Array:
	var neighbors: Array = []
	var main: Main = $/root/Main
	for neighbor in $/root/Main/Neighborhood/Neighbors.get_children():
		if neighbor is NeighborNPC:
			if neighbor.level < 0:
				continue
			if neighbor.disabled:
				continue
			if neighbor.level < main.current_level:
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
	start_index: int = 0,
	add_done_label: bool = false
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
		button.text = " %s" % neighbor.display_name
		if add_done_label and neighbor.times_mowed > 0:
			button.text += " (DONE)"
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

func activate() -> void:
	$InfoScreen.show()
	buttons.clear()
	neighbor_paths.clear()

	var main: Main = $/root/Main
	# Create the list of lawns the player has previously mowed
	var prev_neighbors = get_prev_neighbors()
	$InfoScreen/QuestBox/PrevLawnsLabel.visible = !prev_neighbors.is_empty()
	$InfoScreen/QuestBox/PrevLawns.visible = !prev_neighbors.is_empty()
	var index = add_neighbor_buttons($InfoScreen/QuestBox/PrevLawns/List, prev_neighbors, 0)

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
		$InfoScreen/QuestBox/Reward.hide()
		$InfoScreen/QuestBox/Goals.hide()
		$InfoScreen/QuestBox/MowingGoal.hide()
		$InfoScreen/QuestBox/Lawns.hide()
		return
	$InfoScreen/QuestBox/TODO.show()
	$InfoScreen/QuestBox/Spacing.show()
	$InfoScreen/QuestBox/Reward.show()
	$InfoScreen/QuestBox/Goals.show()

	# Create the list of lawns that the player has to mow right now
	var current_neighbors = get_current_neighbors()
	$InfoScreen/QuestBox/MowingGoal.visible = !current_neighbors.is_empty()
	if Quest.completed_neighbors(current_neighbors):
		$InfoScreen/QuestBox/MowingGoal.text = " - Mow lawns: (DONE)"
	else:
		$InfoScreen/QuestBox/MowingGoal.text = " - Mow lawns:"
	$InfoScreen/QuestBox/Lawns.visible = !current_neighbors.is_empty()
	add_neighbor_buttons($InfoScreen/QuestBox/Lawns/List, current_neighbors, index, true)
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

	# Set up reward button
	$InfoScreen/QuestBox/Reward/RewardButton.text = " %s " % current_quest.reward.description
	$InfoScreen/QuestBox/Reward/RewardButton.disabled = !current_quest.completed(main, current_neighbors)	

# Toggle the visibility of the screen
func toggle() -> void:
	if $InfoScreen.visible:
		$InfoScreen.hide()
	else:
		activate()

func _on_button_pressed() -> void:
	toggle()

func _process(_delta: float) -> void:
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

func _on_reward_button_pressed() -> void:
	var main: Main = $/root/Main
	var current_quest: Quest = Quest.get_quest(main.current_level)
	if current_quest == null:
		return
	current_quest.reward.give.call(main)
	main.current_level += 1
	selected = -1
	$/root/Main/Player/NeighborArrow.point_to = ""
	activate()

func reset() -> void:
	buttons.clear()
	neighbor_paths.clear()
	selected = -1
