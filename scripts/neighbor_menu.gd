extends Panel

var current_neighbor: NeighborNPC

func _ready() -> void:
	hide_menu()

func format_wage(wage: int) -> String:
	return "I will pay you <$%d> to mow my lawn." % wage

func set_menu(neighbor: NeighborNPC) -> void:
	$VBoxContainer/Name.text = neighbor.display_name
	$VBoxContainer/Wage.text = format_wage(neighbor.wage)
	$VBoxContainer/Description.text = neighbor.current_dialog
	$VBoxContainer/HBoxContainer/Accept.disabled = false
	$VBoxContainer/HBoxContainer/Leave.disabled = false
	current_neighbor = neighbor
	show()

func hide_menu() -> void:
	hide()
	$VBoxContainer/HBoxContainer/Accept.disabled = true
	$VBoxContainer/HBoxContainer/Leave.disabled = true

func _on_leave_pressed() -> void:
	hide_menu()
	current_neighbor.hide()

func _on_accept_pressed() -> void:
	hide_menu()
	current_neighbor.hide()
	$/root/Main.load_lawn(current_neighbor.lawn_template)
	$/root/Main.current_wage = current_neighbor.wage
