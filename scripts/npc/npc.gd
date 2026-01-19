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
@export var use_female_voice: bool = false
var first_dialog: PackedStringArray = [ "Hello!" ]
var player_dialog: PackedStringArray = [ "Hello!" ]
var possible_dialog: PackedStringArray = []
@export_multiline var interact_text = ""
@export var dialog_json: JSON

var current_dialog: String = ""
var player_in_area: bool = false

func _ready() -> void:
	if interact_text.is_empty():
		interact_text = "talk to %s" % display_name

	play(animation)
	Dialog.set_npc_dialog_from_json(self, dialog_json)

func generate_dialog() -> void:
	current_dialog = ""
	if first_time and !first_dialog.is_empty():
		return
	
	if possible_dialog.is_empty():
		return
	current_dialog = possible_dialog[randi() % len(possible_dialog)]

func _process(_delta: float) -> void:
	var menu_visible = $/root/Main/HUD/Control/NPCMenu.visible
	# Have the player interact with the neighbor
	if Input.is_action_just_pressed("interact") and player_in_area and !menu_visible:
		$/root/Main.play_sfx("Click")
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
	first_time = Save.get_val(data, "first_time", true)
