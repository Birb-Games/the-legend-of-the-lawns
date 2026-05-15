# Assumes that we have music tracks as child AudioStreamPlayer nodes that can
# be turned on and off as needed

extends Node

class_name MusicController

# Stops playing all music
func clear_music() -> void:
	for music: AudioStreamPlayer in get_children():
		music.stop()

# starts playing a music track
func play_music(id: String) -> void:
	clear_music()
	var music = get_node_or_null(id)
	if music == null:
		printerr("Invalid music id: %s" % id)
		return
	if music is AudioStreamPlayer:
		# Clear all other tracks to prevent different tracks from playing at the
		# same time
		clear_music()
		music.play()
