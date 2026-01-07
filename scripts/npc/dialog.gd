class_name Dialog

const DEFAULT_POSSIBLE_DIALOG: PackedStringArray = [
	"Oh, you want to mow my lawn? I suppose it is a bit overgrown...",
	"My lawn needs to be mowed today but I'm too lazy.",
]
const DEFAULT_REJECT_DIALOG: PackedStringArray = [
	"Sorry, my lawn doesn't need to be mowed today.",
]
const DEFAULT_FIRST_DIALOG: PackedStringArray = [
	"Hello!",
]
const DEFAULT_UNAVAILABLE_MSG: String = "The door is locked..."
const DEFAULT_FIRST_JOB_OFFER: String = "I suppose I could use some help with mowing my lawn today..."
const DEFAULT_PLAYER_DIALOG: PackedStringArray = [ "I'm here to mow your lawn!" ]

static func set_neighbor_dialog_from_json(neighbor: NeighborNPC, json: JSON) -> void:
	if json == null:
		return
	neighbor.possible_dialog = Save.get_val(json.data, "possible_dialog", DEFAULT_POSSIBLE_DIALOG)
	neighbor.reject_dialog = Save.get_val(json.data, "reject_dialog", DEFAULT_REJECT_DIALOG)
	neighbor.unavailable_msg = Save.get_val(json.data, "unavailable_msg", DEFAULT_UNAVAILABLE_MSG)
	neighbor.first_dialog = Save.get_val(json.data, "first_dialog", DEFAULT_FIRST_DIALOG)
	neighbor.player_dialog = Save.get_val(json.data, "player_dialog", DEFAULT_PLAYER_DIALOG)
	neighbor.first_job_offer = Save.get_val(json.data, "first_job_offer", DEFAULT_FIRST_JOB_OFFER)

static func set_npc_dialog_from_json(npc: NPC, json: JSON) -> void:
	if json == null:
		return
	npc.possible_dialog = Save.get_val(json.data, "possible_dialog", [])
	npc.first_dialog = Save.get_val(json.data, "first_dialog", [ "Hello!" ])
	npc.player_dialog = Save.get_val(json.data, "player_dialog", [ "Hello!" ])
