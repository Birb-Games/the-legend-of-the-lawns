# To avoid confusion,
# "NeighborNPC" refers to npcs that will give the player the opportunity to mow
# their yard while "NPC" refers to generic chracters that the player can talk
# to but can not take a job from.

class_name NPC

extends AnimatedSprite2D

@export var display_name: String = "NPC"
# Set this to false if you do not want a first time dialog
@export var first_time: bool = true

@export_group("Dialog")
@export_multiline var first_dialog: String = "Hello!"
@export_multiline var player_dialog: String = "Hello!"
@export_multiline var possible_dialog: PackedStringArray = []
@export_multiline var interact_text = ""

var current_dialog: String = ""
var player_in_area: bool = false

func _ready() -> void:
	if len(interact_text) == 0:
		interact_text = "talk to %s" % display_name

	play(animation)

func generate_dialog() -> void:
	current_dialog = ""
	if first_time:
		current_dialog = first_dialog
		return
	
	if len(possible_dialog) == 0:
		return
	current_dialog = possible_dialog[randi() % len(possible_dialog)]

func _process(_delta: float) -> void:
	var menu_visible = $/root/Main/HUD/Control/NPCMenu.visible
	# Have the player interact with the neighbor
	if Input.is_action_just_pressed("interact") and player_in_area and !menu_visible:
		generate_dialog()
		$/root/Main/HUD.set_npc_menu(self)

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		player_in_area = true	
		body.interact_text = "Press [SPACE] to %s." % interact_text

func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		player_in_area = false	
		body.interact_text = ""

func save() -> Dictionary:
	return {
		"path" : get_path(),
		"first_time" : first_time,
	}

func load_from(data: Dictionary) -> void:
	first_time = data["first_time"]
