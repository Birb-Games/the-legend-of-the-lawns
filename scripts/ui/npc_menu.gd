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

func set_menu_unavailable(neighbor: NeighborNPC) -> void:
	$Menu/VBoxContainer/Name.text = "???"
	var lawns_left = neighbor.min_lawns_mowed - $/root/Main.lawns_mowed
	if lawns_left == 1:
		$Menu/VBoxContainer/Wage.text = "Mow <1> more lawn, then come back."
	elif lawns_left > 1:
		$Menu/VBoxContainer/Wage.text = "Mow <%d> more lawns, then come back." % lawns_left
	$Menu/VBoxContainer/Description.text = neighbor.current_dialog
	buttons[0].show()
	buttons[0].text = "Leave"
	buttons[0].connect("pressed", on_leave_pressed)
	show()

func set_menu_reject(neighbor: NeighborNPC) -> void:
	$Menu/VBoxContainer/Name.text = neighbor.display_name
	$Menu/VBoxContainer/Wage.text = ""
	$Menu/VBoxContainer/Description.text = neighbor.current_dialog

	buttons[0].show()
	buttons[0].text = "Leave"
	buttons[0].connect("pressed", on_leave_pressed)
	show()

func advance_first_dialog() -> void:
	current_neighbor.first_time = false
	current_neighbor.current_dialog = current_neighbor.first_job_offer
	set_menu(current_neighbor)

func set_menu_first(neighbor: NeighborNPC) -> void:
	$Menu/VBoxContainer/Name.text = neighbor.display_name
	$Menu/VBoxContainer/Wage.text = ""
	$Menu/VBoxContainer/Description.text = neighbor.current_dialog

	buttons[0].show()
	buttons[0].text = neighbor.player_dialog
	buttons[0].connect("pressed", advance_first_dialog)
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

	if neighbor.first_time:
		set_menu_first(neighbor)
		return
	
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

func advance_first_dialog_npc() -> void:
	current_npc.first_time = false
	current_npc.generate_dialog()
	set_npc_menu(current_npc)

func set_npc_menu(npc: NPC) -> void:
	reset_buttons()
	$Menu/VBoxContainer/Wage.hide()

	current_npc = npc
	$Menu/VBoxContainer/Name.text = npc.display_name
	$Menu/VBoxContainer/Wage.text = ""
	$Menu/VBoxContainer/Description.text = npc.current_dialog

	buttons[0].show()

	if !npc.first_time:
		buttons[0].text = "Leave"
		buttons[0].connect("pressed", on_leave_pressed)
	else:
		buttons[0].text = npc.player_dialog
		buttons[0].connect("pressed", advance_first_dialog_npc)

	show()

func skip_day() -> void:
	var main: Main = $/root/Main
	main.advance_day()
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
	$/root/Main.load_lawn(current_neighbor.lawn_template)
	$/root/Main.current_wage = current_neighbor.wage
