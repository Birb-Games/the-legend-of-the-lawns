extends Control 

var current_neighbor: NeighborNPC
var current_npc: NPC

@onready var buttons: Array[Button] = [
	$Menu/VBoxContainer/HBoxContainer/Button1,
	$Menu/VBoxContainer/HBoxContainer/Button2,
	$Menu/VBoxContainer/HBoxContainer/Button3,
	$Menu/VBoxContainer/HBoxContainer/Button4,
]

func hide_neighbor() -> void:
	if current_neighbor != null and !current_neighbor.always_visible:
		current_neighbor.hide()

func reset_buttons() -> void:
	for button in buttons:
		button.hide()
		button.text = ""
		# Disconnect the pressed signal
		var connections = button.get_signal_connection_list("pressed")
		for conn in connections:
			button.disconnect("pressed", conn.callable)

static func format_wage(wage: int) -> String:
	return "I will pay you <$%d> to mow my lawn." % wage

# This is the message displayed if the neighbor is not unlocked yet.
func set_menu_unavailable(neighbor: NeighborNPC) -> void:
	$Menu/VBoxContainer/Name.text = "???"
	$Menu/VBoxContainer/Wage.text = ""
	$Menu/VBoxContainer/Description.text = neighbor.current_dialog
	buttons[0].show()
	buttons[0].text = "Leave"
	buttons[0].connect("pressed", on_leave_pressed)
	show()

# This is the message displayed if the neighbor does not need their lawn mowed.
func set_menu_reject(neighbor: NeighborNPC) -> void:
	$Menu/VBoxContainer/Name.text = neighbor.display_name
	$Menu/VBoxContainer/Wage.text = ""
	$Menu/VBoxContainer/Description.text = neighbor.current_dialog
	buttons[0].show()
	buttons[0].text = "Leave"
	buttons[0].connect("pressed", on_leave_pressed)
	show()

# Advances the initial conversation the player has with the neighbor.
func advance_first_dialog(neighbor: NeighborNPC, index: int) -> void:
	if index + 1 < len(current_neighbor.first_dialog):
		reset_buttons()
		set_menu_first(neighbor, index + 1)
		return
	current_neighbor.first_time = false
	current_neighbor.current_dialog = current_neighbor.first_job_offer
	set_menu(current_neighbor)

# This displays the conversation that the player has with the neighbor npc
# when they first meet them.
func set_menu_first(neighbor: NeighborNPC, index: int) -> void:
	$Menu/VBoxContainer/Name.text = neighbor.display_name
	$Menu/VBoxContainer/Wage.text = ""
	$Menu/VBoxContainer/Description.text = neighbor.first_dialog[index]

	buttons[0].show()
	if index < len(neighbor.player_dialog):
		buttons[0].text = neighbor.player_dialog[index]
	else:
		buttons[0].text = "Okay"
	buttons[0].connect(
		"pressed", 
		func() -> void: 
			advance_first_dialog(neighbor, index)
	)
	show()

# This is the menu displayed if the player can mow the neighbor's lawn.
func set_mowing_menu(neighbor: NeighborNPC) -> void:
	$Menu/VBoxContainer/Name.text = neighbor.display_name
	$Menu/VBoxContainer/Wage.text = format_wage(neighbor.wage) 
	$Menu/VBoxContainer/Description.text = neighbor.current_dialog	
	
	buttons[0].show()
	buttons[0].text = "Nah"
	buttons[0].connect("pressed", on_leave_pressed)
	
	buttons[1].show()
	buttons[1].text = "Deal!"
	buttons[1].connect("pressed", on_accept_pressed)
	
	show()

func set_menu(neighbor: NeighborNPC) -> void:
	reset_buttons()
	$Menu/VBoxContainer/Wage.show()

	current_neighbor = neighbor
	
	if neighbor.unavailable():
		set_menu_unavailable(neighbor)
		return

	if neighbor.reject():
		set_menu_reject(neighbor)
		return

	if neighbor.first_time and !neighbor.first_dialog.is_empty():
		set_menu_first(neighbor, 0)
		return

	set_mowing_menu(neighbor)

func set_menu_first_npc(npc: NPC, index: int) -> void:
	$Menu/VBoxContainer/Description.text = npc.first_dialog[index]
	if index < len(npc.player_dialog):
		buttons[0].text = npc.player_dialog[index]
	else:
		buttons[0].text = "Okay"
	if index < len(npc.first_dialog) - 1:
		buttons[0].connect(
			"pressed",
			func() -> void:
				reset_buttons()
				set_menu_first_npc(npc, index + 1)
		)
	else:
		npc.first_time = false
		buttons[0].connect("pressed", on_leave_pressed)
	buttons[0].show()
	show()

func set_npc_menu(npc: NPC) -> void:
	reset_buttons()
	$Menu/VBoxContainer/Wage.hide()

	current_npc = npc
	$Menu/VBoxContainer/Name.text = npc.display_name
	$Menu/VBoxContainer/Wage.text = ""
	$Menu/VBoxContainer/Description.text = npc.current_dialog

	buttons[0].show()

	if npc.first_time and !npc.first_dialog.is_empty():
		set_menu_first_npc(npc, 0)
	else:
		buttons[0].text = "Leave"
		buttons[0].connect("pressed", on_leave_pressed)

	show()

func set_bus_menu(bus_stop: BusStop) -> void:
	reset_buttons()

	$Menu/VBoxContainer/Name.text = "Bus Stop (%s)" % bus_stop.display_name
	$Menu/VBoxContainer/Description.text = "Select your desired destination."
	$Menu/VBoxContainer/Wage.text = ""

	buttons[0].text = "Leave"
	buttons[0].connect("pressed", on_leave_pressed)
	buttons[0].show()

	show()

	var index = 1
	for stop: BusStop in bus_stop.connections:
		if index >= len(buttons):
			break
		buttons[index].text = stop.display_name
		buttons[index].connect(
			"pressed", 
			func() -> void:
				# Teleport the player to the appropriate bus stop
				var player: Player = $/root/Main/Player
				player.position = stop.position + Vector2(16.0, 6.0)
				player.dir = "down"
				# Activate transition animation
				$/root/Main/HUD/Control/TransitionRect.start_bus_animation()
				$/root/Main/Player/Camera2D.position_smoothing_enabled = false
				# 'Leave' the menu
				on_leave_pressed()
		)
		buttons[index].show()
		index += 1

func set_job_board_menu(job_board: JobBoard) -> void:
	reset_buttons()
	$Menu/VBoxContainer/Name.text = "Job Board"

	buttons[0].text = "Okay"
	buttons[0].connect("pressed", on_leave_pressed)
	buttons[0].show()

	var main: Main = $/root/Main
	var current_quest: Quest = Quest.get_quest(main.current_level)
	if current_quest and current_quest.completed(main):
		$Menu/VBoxContainer/Description.text = "TO-DO list completed, reward claimed! (%s)" % current_quest.reward.description
		main.advance_quest()
		job_board.current_job = null
		if Quest.get_quest(main.current_level):
			$Menu/VBoxContainer/Wage.text = "New TO-DOs added to journal!"
			$/root/Main/HUD/Control/QuestScreen.show_alert = true
		else:
			$Menu/VBoxContainer/Wage.text = ""
		show()
		return

	if job_board.current_job == null:
		$Menu/VBoxContainer/Description.text = "No lawn mowing jobs are currently available."
		$Menu/VBoxContainer/Wage.text = "Come back later!"
	else:
		var neighbor: NeighborNPC = get_node_or_null(job_board.current_job.neighbor_path)
		$Menu/VBoxContainer/Description.text = job_board.current_job.get_message(neighbor)
		$Menu/VBoxContainer/Wage.text = "Job added to journal!"
		$/root/Main/HUD/Control/QuestScreen.show_alert = true
		if neighbor:
			main.job_list[neighbor.name] = job_board.current_job
		job_board.generate_job()

	show()

func skip_day() -> void:
	var main: Main = $/root/Main
	main.advance_day()
	$/root/Main/Neighborhood/JobBoard.update()
	main.save_progress()
	var player: Player = $/root/Main/Player
	player.dir = "down"
	player.position = main.player_pos
	hide()

func set_skip_day_menu() -> void:
	current_npc = null
	current_neighbor = null
	reset_buttons()
	$Menu/VBoxContainer/Wage.hide()

	$Menu/VBoxContainer/Name.text = "Your House"
	$Menu/VBoxContainer/Wage.text = ""
	$Menu/VBoxContainer/Description.text = """
Are you sure you want to go inside and play games on itch.io for the rest of the day?
"""
	
	buttons[0].show()
	buttons[0].text = "No, I should mow a lawn."
	buttons[0].connect("pressed", on_leave_pressed)

	buttons[1].show()
	buttons[1].text = "Yes (skip day)"
	buttons[1].connect("pressed", skip_day)

	show()

func on_leave_pressed() -> void:
	hide()
	hide_neighbor()

func on_accept_pressed() -> void:
	hide()
	hide_neighbor()
	var difficulty = current_neighbor.times_mowed
	if current_neighbor.max_difficulty > 0:
		difficulty = min(difficulty, current_neighbor.max_difficulty)
	$/root/Main.load_lawn(current_neighbor.lawn_template, difficulty)
	$/root/Main.current_wage = current_neighbor.wage
