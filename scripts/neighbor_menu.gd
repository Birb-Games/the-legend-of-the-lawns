extends Control 

var current_neighbor: NeighborNPC

@onready var buttons: Array[Button] = [
	$Menu/VBoxContainer/HBoxContainer/Button1,
	$Menu/VBoxContainer/HBoxContainer/Button2,
	$Menu/VBoxContainer/HBoxContainer/Button3,
	$Menu/VBoxContainer/HBoxContainer/Button4,
]

func hide_neighbor() -> void:
	if current_neighbor != null:
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
	$Menu/VBoxContainer/Name.text = ""
	$Menu/VBoxContainer/Wage.text = ""
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

func set_menu(neighbor: NeighborNPC) -> void:
	reset_buttons()

	if neighbor.unavailable():
		set_menu_unavailable(neighbor)
		return
	
	if neighbor.reject():
		set_menu_reject(neighbor)
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
	
	current_neighbor = neighbor
	show()

func on_leave_pressed() -> void:
	hide()
	hide_neighbor()

func on_accept_pressed() -> void:
	hide()
	hide_neighbor()
	$/root/Main.load_lawn(current_neighbor.lawn_template)
	$/root/Main.current_wage = current_neighbor.wage
