# To avoid confusion,
# "NeighborNPC" refers to npcs that will give the player the opportunity to mow
# their yard while "NPC" refers to generic chracters that the player can talk
# to but can not take a job from.

class_name NeighborNPC

extends AnimatedSprite2D

var player_in_area: bool = false

@export var display_name: String = "Neighbor"
@export var always_visible: bool = false
@export var disabled: bool = false
@export var is_test: bool = false
@export var lawn_template: PackedScene
@export var max_difficulty: int = 0
var times_mowed: int = 0
# The player has to mow this many lawns before this neighbor is available again
# on the job board
var cooldown: int = 0
@export var level: int = -1
@export var knock_sound: AudioStreamPlayer

@export_group("Wage Info")
@export var wage: int = 10
@export var max_wage: int = 20
@export var bonus_base: int = 2
@export var max_bonus: int = 5
## How much they remove from the player's wage when they destroy each flower
@export var flower_penalty: int = 0
## How much they remove from the player's wage when they destroy each hedge
@export var hedge_penalty: int = 0

@export_group("Dialog")
@export var use_female_voice: bool = false
@export_multiline var interact_text: String = "Press [SPACE] to knock on door."
var possible_dialog: PackedStringArray = Dialog.DEFAULT_POSSIBLE_DIALOG
var reject_dialog: PackedStringArray = Dialog.DEFAULT_REJECT_DIALOG
var unavailable_msg: String = Dialog.DEFAULT_UNAVAILABLE_MSG
var first_dialog: PackedStringArray = Dialog.DEFAULT_FIRST_DIALOG
var player_dialog: PackedStringArray = Dialog.DEFAULT_PLAYER_DIALOG
var first_job_offer: String = Dialog.DEFAULT_FIRST_JOB_OFFER
@export var dialog_json: JSON
var first_time: bool = true

var current_dialog: String = ""

func _ready() -> void:
	$Area2D/CollisionShape2D.disabled = disabled
	hide()
	play(animation)
	Dialog.set_neighbor_dialog_from_json(self, dialog_json)
	if knock_sound == null:
		knock_sound = get_node_or_null("/root/Main/Sfx/DoorKnock")

func unavailable() -> bool:
	return $/root/Main.current_level < level 

func reject() -> bool:
	var main: Main = $/root/Main
	return times_mowed > 0 and !(name in main.job_list) and !is_test

func generate_dialog() -> void:
	current_dialog = ""
	if unavailable():
		current_dialog = unavailable_msg
		return
	if reject():
		if reject_dialog.is_empty():
			return
		current_dialog = reject_dialog[randi() % len(reject_dialog)]
		return
	if first_time and !first_dialog.is_empty():
		return
	
	if possible_dialog.is_empty():
		return
	current_dialog = possible_dialog[randi() % len(possible_dialog)]

func set_menu() -> void:
	if !unavailable():
		show()
	$/root/Main/HUD.set_neighbor_menu(self)
	$/root/Main/Player.can_move = true
	$/root/Main/Player.interact_text = interact_text
	knock_sound.disconnect("finished", set_menu)

func _process(_delta: float) -> void:
	if disabled:
		return

	# Have the player interact with the neighbor
	if Input.is_action_just_pressed("interact") and player_in_area and (!visible or always_visible):
		generate_dialog()
		if knock_sound and !knock_sound.playing and !$/root/Main/HUD.npc_menu_open():
			knock_sound.play()
			knock_sound.connect("finished", set_menu)
			$/root/Main/Player.can_move = false
			$/root/Main/Player.interact_text = "*knock knock*"
	if always_visible:
		show()

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		player_in_area = true
		body.interact_text = interact_text

func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		player_in_area = false	
		body.interact_text = ""

func save() -> Dictionary:
	return {
		"path" : get_path(),
		"times_mowed" : times_mowed,
		"first_time" : first_time,
		"cooldown" : cooldown
	}

func load_from(data: Dictionary) -> void:
	times_mowed = Save.get_val(data, "times_mowed", 0)
	first_time = Save.get_val(data, "first_time", true)
	cooldown = Save.get_val(data, "cooldown", 0)
