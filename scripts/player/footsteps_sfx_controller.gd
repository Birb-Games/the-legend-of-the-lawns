extends Node

@onready var main: Main = $/root/Main
@onready var player: Player = get_parent()

const GRASS_TILES = [
	LawnGenerationUtilities.GRASS,
	LawnGenerationUtilities.CUT_GRASS,
	LawnGenerationUtilities.DESTROYED_HEDGE,
	Vector2i(7, 1),
	# 'Garden' tiles
	Vector2i(3, 3),
	Vector2i(4, 3),
	Vector2i(5, 3),
	Vector2i(6, 3),
]

const WOOD: Vector2i = Vector2i(3, 1)

func get_tile_noise(tile: Vector2i, source_id: int) -> AudioStreamPlayer:
	match source_id:
		0:
			if (tile in GRASS_TILES):
				return $FootstepsGrass
			else:
				return $Footsteps
		1:
			return $FootstepsWood
	return null

func play_sound(tile: Vector2i, source_id: int) -> void:
	# print(tile, ' ', id)
	var to_play: AudioStreamPlayer = get_tile_noise(tile, source_id)
	for child: AudioStreamPlayer in get_children():
		if child.playing and child != to_play:
			child.stop()
		elif !child.playing and child == to_play:
			child.play()

func _process(_delta: float) -> void:
	if player.velocity.length() == 0.0 or player.lawn_mower_active():
		return
	# Ignore if the player is dead
	if player.health <= 0:
		return

	if !main.lawn_loaded:
		# Check which tile the player is standing on
		var tilemap: TileMapLayer = $/root/Main/Neighborhood/TileMapLayer
		var tile_size = tilemap.tile_set.tile_size
		var player_tile_pos: Vector2i = Vector2i(
			int(floor(player.global_position.x / tile_size.x)),
			int(floor(player.global_position.y / tile_size.y))
		)
		var tile: Vector2i = tilemap.get_cell_atlas_coords(player_tile_pos)
		var source_id: int = tilemap.get_cell_source_id(player_tile_pos)
		play_sound(tile, source_id)
	else:
		# Check which tile the player is standing on
		var lawn: Lawn = $/root/Main/Lawn
		var tile_size = lawn.tile_size
		var player_tile_pos: Vector2i = Vector2i(
			int(floor(player.global_position.x / tile_size.x)),
			int(floor(player.global_position.y / tile_size.y))
		)
		var tile: Vector2i = lawn.get_tile(player_tile_pos.x, player_tile_pos.y)
		var source_id: int = $/root/Main/Lawn/TileMapLayer.get_cell_source_id(player_tile_pos)
		play_sound(tile, source_id)
