extends Control

@onready var title_y: float = $Title.position.y
const START_SPEED: float = 300.0
const ACCELERATION: float = 80.0
var title_speed: float = START_SPEED
var update_title: bool = false

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
	$Stats/Wage.text = "Earned $%d" % main.current_wage
	$Stats/Total.text = "Total: $%d" % (main.money + main.current_wage)

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
	main.update_wage()
	main.advance_day()
	main.return_to_neighborhood()
	var current_neighbor: NeighborNPC = $/root/Main/HUD.get_current_neighbor()
	current_neighbor.difficulty += 1
	current_neighbor.change_wage()
	current_neighbor.set_cooldown()
