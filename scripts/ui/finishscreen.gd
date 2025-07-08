extends Control

@onready var title_y: float = $Title.position.y
const START_SPEED: float = 300.0
const ACCELERATION: float = 80.0
var title_speed: float = START_SPEED
var update_title: bool = false

# The penalties and bonuses to be added to the wage
var current_wage_modifier: int = 0

const DELAY: float = 1.0
var timer: float = 0.0

func activate():
	timer = DELAY
	show()
	$TileMapLayer.hide()
	$Stats.hide()
	$HBoxContainer.hide()
	$Title.position.y = -100.0
	update_title = false
	
func start_showing_menu():
	$TileMapLayer.show()
	title_speed = START_SPEED
	update_title = true
	var main = $/root/Main
	$Stats/Wage.text = "Wage $%d" % main.current_wage

	var flower_penalty: int = $/root/Main/Lawn.flowers_destroyed * $/root/Main/HUD.get_current_neighbor().flower_penalty
	if flower_penalty == 0:
		$Stats/FlowerPenalty.hide()
	else:
		current_wage_modifier -= flower_penalty
		$Stats/FlowerPenalty.show()
		$Stats/FlowerPenalty.text = "Flower Penalty: -$%d" % flower_penalty
	
	var hedge_penalty: int = calculate_hedge_penalty()
	if hedge_penalty == 0:
		$Stats/HedgePenalty.hide()
	else:
		current_wage_modifier -= hedge_penalty
		$Stats/HedgePenalty.show()
		$Stats/HedgePenalty.text = "Hedge Penalty: -$%d" % hedge_penalty
	
	# Time bonus, currently a reciprocal function
	var time_bonus: int = roundi(120.0 / $/root/Main/HUD.time_elapsed)
	$Stats/TimeBonus.text = "Time Bonus: $%d" % time_bonus
	current_wage_modifier += time_bonus

	$Stats/Earned.text = "Earned: $%d" % (main.current_wage + current_wage_modifier)

	$Stats/Total.text = "Total: $%d" % (main.money + main.current_wage + current_wage_modifier)

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

func _on_return_pressed() -> void:
	get_tree().paused = false
	hide()
	var main: Main = $/root/Main
	main.lawns_mowed += 1
	main.update_money(current_wage_modifier)
	main.advance_day()
	main.return_to_neighborhood()
	var current_neighbor: NeighborNPC = $/root/Main/HUD.get_current_neighbor()
	current_neighbor.difficulty += 1
	current_neighbor.change_wage()
	current_neighbor.set_cooldown()

func calculate_hedge_penalty():
	var tileMapLayer: TileMapLayer = $/root/Main/Lawn/TileMapLayer
	var destroyed_hedges: int = 0
	for tile in tileMapLayer.get_used_cells():
		if tileMapLayer.get_cell_atlas_coords(tile) == Vector2i(0, 2):
			destroyed_hedges += 1
	return destroyed_hedges * $/root/Main/HUD.get_current_neighbor().hedge_penalty
