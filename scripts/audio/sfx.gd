extends AudioStreamPlayer2D

class_name Sfx

static var sfx_table: Dictionary = {
	"explosion" : preload("uid://bivk14fhubfl7"),
	"pop" : preload("uid://br1dxxe5eme6f"),
}

func _on_finished() -> void:
	queue_free()

static func play_at_pos(pos: Vector2, id: String, parent: Node, volume: float = 1.0) -> void:
	if parent == null:
		return
	if !(id in sfx_table):
		printerr("%s not found in sfx table!" % id)
		return
	var sfx: Sfx = sfx_table[id].instantiate()
	sfx.volume_linear *= volume
	sfx.global_position = pos 
	parent.add_child(sfx)
