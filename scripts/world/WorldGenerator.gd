extends ProceduralGenerator
signal world_generated(terrain_tiles)
tool

export(int, 0, 200, 2) var width = 100 setget _set_width
export(int, 0, 200, 2) var ground_height = 50 setget _set_ground_height
export(int, 0, 200, 2) var cave_height = 100 setget _set_cave_height

const EDGE_SOFTENING = 5
var _foreground : TileMap = null
var _background : TileMap = null

var noise_list = {
	ground_height = Noise.new(),
	cave = Noise.new(),
	minerals = Noise.new(),
}


# ------------------------------------------------------------------------------
func _set_width(value : int) -> void:
	width = value
	
	if Engine.editor_hint:
		generate()


# ------------------------------------------------------------------------------
func _set_cave_height(value : int) -> void:
	cave_height = value
	
	if Engine.editor_hint:
		generate()


# ------------------------------------------------------------------------------
func _set_ground_height(value : int) -> void:
	ground_height = value
	
	if Engine.editor_hint:
		generate()


# ------------------------------------------------------------------------------
func _get_noise_dict() -> Dictionary:
	return noise_list


# ------------------------------------------------------------------------------
func clear():
	if (_foreground != null and _background != null) or _get_tilemaps():
		_foreground.clear()
		_background.clear()


# ------------------------------------------------------------------------------
func generate():
	
	if (_foreground != null and _background != null) or _get_tilemaps():
		
		var tiles = []
		
		for x in width:
			tiles.append([])
			
			for y in cave_height + ground_height:
				tiles[x].append(-1)
		
		noise_list.ground_height._noise.seed = noise_seed
		noise_list.cave._noise.seed = noise_seed
		noise_list.minerals._noise.seed = noise_seed
		
		_generate_ground_height(tiles)
		
		for x in width:

			for y in range(ground_height, ground_height + cave_height):	

				var noise_sample = noise_list.cave._noise.get_noise_2d(x, y)
				var normalised_sample = (noise_sample + 1.0) * 0.5
				normalised_sample = min(normalised_sample 
					+ _get_edge_dist_modifier(x, y), 1)

				tiles[x][y] = _get_tile_from_cave_sample(normalised_sample)

				if 0 == tiles[x][y]:
					noise_sample = noise_list.minerals._noise.get_noise_2d(float(x), float(y))
					tiles[x][y] = _get_tile_from_mineral(noise_sample)
		
		emit_signal("world_generated", tiles)
		_apply_tiles_to_tilemap(tiles)
	else:
		print("No tiles")


# ------------------------------------------------------------------------------
func _generate_ground_height(tiles : Array):
	for x in width:
		var sample = noise_list.ground_height._noise.get_noise_1d(x)
		var ground_y = (sample + 1.0) * 0.5 * ground_height
		
		for y in range(ground_y, ground_height):
			tiles[x][y] = 0
	

# ------------------------------------------------------------------------------
func _get_tile_from_cave_sample(noise_sample):
	if noise_list.cave._params["sign"]:
		if noise_sample > noise_list.cave._params["split"]:
			return 0
		return -1
		
	else:
		if noise_sample < noise_list.cave._params["split"]:
			return 0
		return -1


# ------------------------------------------------------------------------------
func _get_tile_from_mineral(noise_sample):
	var normalised_sample = (noise_sample + 1.0) * 0.5
	
	if normalised_sample > noise_list.minerals._params["split"]:
		return 2
	return 0


# ------------------------------------------------------------------------------
func _get_edge_dist_modifier(x, y):
	var total_height = cave_height + ground_height
	
	var bottom = 1 - (min(total_height - y, EDGE_SOFTENING) / EDGE_SOFTENING)
	var left = 1 - (min(x, EDGE_SOFTENING) / EDGE_SOFTENING)
	var right = 1 - (min(width - x, EDGE_SOFTENING) / EDGE_SOFTENING)
	
	return (bottom + left + right) * 0.3


# ------------------------------------------------------------------------------
func _apply_tiles_to_tilemap(tiles : Array):
	
	# Clears any previous world.
	clear()
	
	# Applies the generated caves.
	for x in tiles.size():
		for y in tiles[x].size():
			if y >= ground_height:
				_background.set_cellv(Vector2(x, y), 0)
			_foreground.set_cell(x, y, tiles[x][y])
	
	# Adds a buffer of unbreakable blocks around the level.
	var buffer = 10
	
#	for x in range(-buffer, WIDTH + buffer):
#		for y in range(0, buffer):
#			_foreground.set_cell(x, -1 - y, 1)
#			_foreground.set_cell(x, HEIGHT + y, 1)
#
#	for y in HEIGHT:
#		for x in range(0, buffer):
#			_foreground.set_cell(-1 - x, y, 1)
#			_foreground.set_cell(HEIGHT + x, y, 1)
	
	# Updates the autotiles.
	_foreground.update_bitmask_region(Vector2.ZERO, 
		Vector2(width, cave_height + ground_height))


# ------------------------------------------------------------------------------
func _ready():
	randomize()
	noise_seed = randi()
	
	if Engine.editor_hint:
		call_deferred("clear")

	elif _get_tilemaps():
		generate()


# ------------------------------------------------------------------------------
func _get_tilemaps() -> bool:
	var parent = get_parent()
	if parent != null and parent is Terrain:
		_foreground = parent.get_node("Foreground")
		_background = parent.get_node("Background")
		return _foreground and _background
	else:
		print_debug("No terrain parent")
	return false
	
	
# ------------------------------------------------------------------------------
