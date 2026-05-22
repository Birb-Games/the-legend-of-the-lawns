# Assumes that we have music tracks as child AudioStreamPlayer nodes that can
# be turned on and off as needed

extends Node

class_name MusicController

# This is the flag for if the music is paused
var music_paused: bool = false

# Stops playing all music
func clear_music() -> void:
	for music: AudioStreamPlayer in get_children():
		music.stop()

# Pauses all music
func pause_music() -> void:
	for music: AudioStreamPlayer in get_children():
		music.stream_paused = true

# Unpauses music
func unpause_music() -> void:
	for music: AudioStreamPlayer in get_children():
		music.stream_paused = false

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

# The process mode for this node is set to "Always" since there are times when
# the game is paused and we want to play music (such as on the main menu),
# therefore we check if the pause menu is open to determine whether we should be
# playing music or not.
func _process(_delta: float) -> void:
	# If the pause menu is open, do not play music
	if $/root/Main/HUD.pause_menu_open() and !music_paused:
		pause_music()
		music_paused = true
	# If the pause menu is not open, do not play music
	elif !$/root/Main/HUD.pause_menu_open() and music_paused:
		unpause_music()
		music_paused = false
