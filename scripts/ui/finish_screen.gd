extends Control

@onready var title_y: float = $Title.position.y
const START_SPEED: float = 300.0
const ACCELERATION: float = 80.0
var title_speed: float = START_SPEED
var update_title: bool = false

# The penalties and bonuses to be added to the wage
var current_wage_modifier: int = 0

var labels_to_show = []
const LABEL_DISPLAY_DELAY = 0.5
var label_display_timer: float = LABEL_DISPLAY_DELAY

const DELAY: float = 1.0
var timer: float = 0.0

func activate() -> void:
	if $/root/Main/Player.health <= 0:
		return
	timer = DELAY
	show()
	$TileMapLayer.hide()
	$Stats.hide()
	$HBoxContainer.hide()
	$Title.position.y = -100.0
	update_title = false
	current_wage_modifier = 0
	
func start_showing_menu() -> void:
	label_display_timer = LABEL_DISPLAY_DELAY / 2.0
	$TileMapLayer.show()
	title_speed = START_SPEED
	update_title = true
	var main = $/root/Main
	$Stats/Wage.hide()
	labels_to_show.push_back([$Stats/Wage])
	$Stats/Wage.text = "Wage: $%d" % main.current_wage

	var current_neighbor: NeighborNPC = $/root/Main/HUD.get_current_neighbor();
	var flower_penalty: int = $/root/Main/Lawn.flowers_destroyed * current_neighbor.flower_penalty
	$Stats/FlowerPenalty.hide()
	$Stats/FlowerCommentText.hide()
	if flower_penalty > 0:
		current_wage_modifier -= flower_penalty
		labels_to_show.push_back([$Stats/FlowerPenalty, $Stats/FlowerCommentText])
		$Stats/FlowerPenalty.text = "Flower Penalty: -$%d" % flower_penalty
	
	var hedge_penalty: int = calculate_hedge_penalty()
	$Stats/HedgePenalty.hide()
	$Stats/HedgeCommentText.hide()
	if hedge_penalty > 0:
		current_wage_modifier -= hedge_penalty
		labels_to_show.push_back([$Stats/HedgePenalty, $Stats/HedgeCommentText])
		$Stats/HedgePenalty.text = "Hedge Penalty: -$%d" % hedge_penalty
	
	var time_limit = $/root/Main/Lawn.time_limit
	var time_bonus: int = 0
	# Calculate the time bonus
	if $/root/Main/HUD.time_elapsed < time_limit:
		# if we were able to complete it within the time limit,
		# give the player the base bonus
		time_bonus += current_neighbor.bonus_base
		
		# add an extra bonus for finishing a lawn in a shorter period of time
		var perc = $/root/Main/HUD.time_elapsed / time_limit
		# If done in less than half the time of the bonus time limit, then give
		# the max bonus. Decrease the bonus if it takes longer
		var extra = max(1.0 - max(perc - 0.5, 0.0) * 2.0, 0.0)
		extra *= (current_neighbor.max_bonus - current_neighbor.bonus_base)
		time_bonus += floori(extra)
	time_bonus = min(time_bonus, current_neighbor.max_bonus)
	current_wage_modifier += time_bonus

	$Stats/TimeBonus.hide()
	if time_bonus > 0:
		$Stats/TimeBonus.text = "Time Bonus: $%d" % time_bonus
		labels_to_show.push_back([$Stats/TimeBonus])

	# Payment
	var payment = max(main.current_wage + current_wage_modifier, 0)
	$Stats/Earned.hide()
	labels_to_show.push_back([$Stats/Earned])
	$Stats/Earned.text = "Earned $%d" % payment

	# Total
	$Stats/Total.hide()
	$HBoxContainer/Return.hide()
	labels_to_show.push_back([$Stats/Total, $HBoxContainer/Return])
	$Stats/Total.text = "Total: $%d" % (main.money + payment)

func _process(delta: float) -> void:
	if timer > 0.0:
		timer -= delta
		if timer <= 0.0:
			start_showing_menu()
		return
	
	if update_title:
		$Title.position.y += title_speed * delta
		title_speed += ACCELERATION * delta
	if $Title.position.y >= title_y and update_title:
		update_title = false
		# Show the wage
		$Stats.show()
		$HBoxContainer.show()
		$Title.position.y = title_y

	# Display penalties/bonuses one by one
	if !update_title and len(labels_to_show) > 0:
		label_display_timer -= delta
		if label_display_timer < 0.0:
			var top = labels_to_show.pop_front()
			for label in top:
				label.show()
			label_display_timer = LABEL_DISPLAY_DELAY
			if len(labels_to_show) == 1:
				label_display_timer *= 1.5

func _on_return_pressed() -> void:
	get_tree().paused = false
	hide()
	var main: Main = $/root/Main
	var prev_money: int = main.money
	main.lawns_mowed += 1
	main.update_money(current_wage_modifier)
	main.advance_day()
	var current_neighbor: NeighborNPC = $/root/Main/HUD.get_current_neighbor()	
	if current_neighbor.name in main.job_list:
		main.job_list.erase(current_neighbor.name)
	main.return_to_neighborhood()
	# Update other neighbors's cooldowns
	main.neighborhood.update_neighbors()
	# Set the neighbor cooldown
	current_neighbor.cooldown = randi_range(1, 3)
	$/root/Main/Neighborhood/JobBoard.update()
	if main.money > prev_money:
		current_neighbor.times_mowed += 1
	$/root/Main/Player/Lawnmower.hide()
	main.save_progress()

func calculate_hedge_penalty() -> int:
	var tileMapLayer: TileMapLayer = $/root/Main/Lawn/TileMapLayer
	var destroyed_hedges: int = 0
	for tile in tileMapLayer.get_used_cells():
		if tileMapLayer.get_cell_atlas_coords(tile) == LawnGenerationUtilities.DESTROYED_HEDGE:
			destroyed_hedges += 1
	return destroyed_hedges * $/root/Main/HUD.get_current_neighbor().hedge_penalty
