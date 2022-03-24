extends Node2D
signal world_generated(terrain_tiles)
tool

# ------------------------------------------------------------------------------
# SIMPLEX NOISE PROPERTY DESCRIPTIONS
# ------------------------------------------------------------------------------
# === OCTAVES ===
# Number of OpenSimplex noise layers that are sampled to get the fractal noise. 
# Higher values result in more detailed noise but take more time to generate.
# Have a min vlaue of 1 and max of 9.
#
# === PERIOD ===
# Period of the base octave. A lower period results in higher-frequency noise
# 	(more value changes accross the same distance).
#
# === LACUNARITY ===
# Difference in period between octaves.
#
# === PERSISTENCE ===
# The contribution factor of the different octaves. A persistence value of 1 
# 	means all octaves have the same contribution, a value of 0.5 means each
# 	octave contributes half as much as the previous one.

var params = {
	"cave/octaves": 4,
	"cave/period": 5.076,
	"cave/lacunarity": 0.731,
	"cave/persistence": 1.67,
	"cave/split": 0.489,
	"cave/sign": true,
	
	"minerals/octaves": 2,
	"minerals/period": 64,
	"minerals/lacunarity": 2.0,
	"minerals/persistence": 0.75,
	"minerals/split": 0.489,
}

const WIDTH = 100
const HEIGHT = 100
const EDGE_SOFTENING = 5

func _get_property_list():
	return [
		{ name = "cave/octaves", hint = PROPERTY_HINT_RANGE, hint_string = "1,9,1", type = TYPE_REAL },
		{ name = "cave/period", hint = PROPERTY_HINT_RANGE, hint_string = "0,500", type = TYPE_REAL },
		{ name = "cave/lacunarity", hint = PROPERTY_HINT_RANGE, hint_string = "0,5", type = TYPE_REAL },
		{ name = "cave/persistence", hint = PROPERTY_HINT_RANGE, hint_string = "0,5", type = TYPE_REAL },
		{ name = "cave/split", hint = PROPERTY_HINT_RANGE, hint_string = "0,1", type = TYPE_REAL },
		{ name = "cave/sign", type = TYPE_BOOL },
		{ name = "minerals/octaves", hint = PROPERTY_HINT_RANGE, hint_string = "1,9,1", type = TYPE_REAL },
		{ name = "minerals/period", hint = PROPERTY_HINT_RANGE, hint_string = "-500,500", type = TYPE_REAL },
		{ name = "minerals/lacunarity", hint = PROPERTY_HINT_RANGE, hint_string = "-5,5", type = TYPE_REAL },
		{ name = "minerals/persistence", hint = PROPERTY_HINT_RANGE, hint_string = "-5,5", type = TYPE_REAL },
		{ name = "minerals/split", hint = PROPERTY_HINT_RANGE, hint_string = "0,1", type = TYPE_REAL },
		{ name = "randomize_seed", type = TYPE_BOOL },
		{ name = "clear", type = TYPE_BOOL },
	]
	
var noise_seed = randi()
var _terrain : Terrain = null


# ------------------------------------------------------------------------------
func _set(property, value):
	if params.has(property):
		params[property] = value
		
	if Engine.editor_hint: 
		if property == "randomize_seed":
			noise_seed = randi()
			generate_world()
			
		elif property == "clear":
			clear()
			
		else:
			generate_world()


# ------------------------------------------------------------------------------
func _get(property):
	if params.has(property):
		return params[property]


# ------------------------------------------------------------------------------
func clear():
	if _terrain != null:
		_terrain.clear()


# ------------------------------------------------------------------------------
func generate_world():
	
	var parent = get_parent()
	if parent != null and parent is Terrain:
		_terrain = parent
	else:
		return

	var cave_map = OpenSimplexNoise.new()
	var minerals_map = OpenSimplexNoise.new()
	
	# Sets the cave map noise properties.
	cave_map.seed = noise_seed
	cave_map.octaves = params["cave/octaves"]
	cave_map.period = params["cave/period"]
	cave_map.lacunarity = params["cave/lacunarity"]
	cave_map.persistence = params["cave/persistence"]
	
	minerals_map.seed = noise_seed
	minerals_map.octaves = params["minerals/octaves"]
	minerals_map.period = params["minerals/period"]
	minerals_map.lacunarity = params["minerals/lacunarity"]
	minerals_map.persistence = params["minerals/persistence"]
		
	var tiles = []
	
	for x in WIDTH:
		tiles.append([])
		
		for y in HEIGHT:	
			var noise_sample = cave_map.get_noise_2d(x, y)
			var normalised_sample = (noise_sample + 1.0) * 0.5
			normalised_sample = min(normalised_sample 
				+ _get_edge_dist_modifier(x, y), 1)
			
			tiles[x].append(_get_tile_from_height(normalised_sample))
			
			if _terrain.TileType.Solid == tiles[x][y]:
				noise_sample = minerals_map.get_noise_2d(float(x), float(y))
				tiles[x][y] = _get_tile_from_mineral(noise_sample)
	
	emit_signal("world_generated", tiles)
	_apply_tiles_to_tilemap(tiles)


# ------------------------------------------------------------------------------
func _get_tile_from_height(noise_sample):
	if params["cave/sign"]:
		if noise_sample > params["cave/split"]:
			return _terrain.TileType.Solid
		return _terrain.TileType.Empty
		
	else:
		if noise_sample < params["cave/split"]:
			return _terrain.TileType.Solid
		return _terrain.TileType.Empty


# ------------------------------------------------------------------------------
func _get_tile_from_mineral(noise_sample):
	var normalised_sample = (noise_sample + 1.0) * 0.5
	
	if normalised_sample > params["minerals/split"]:
		return _terrain.TileType.Crystal
	return _terrain.TileType.Solid


# ------------------------------------------------------------------------------
func _get_edge_dist_modifier(x, y):
	var top = 1 - (min(y, EDGE_SOFTENING) / EDGE_SOFTENING)
	var bottom = 1 - (min(HEIGHT - y, EDGE_SOFTENING) / EDGE_SOFTENING)
	var left = 1 - (min(x, EDGE_SOFTENING) / EDGE_SOFTENING)
	var right = 1 - (min(WIDTH - x, EDGE_SOFTENING) / EDGE_SOFTENING)
	return (top + bottom + left + right) / 2.0 * 0.3


# ------------------------------------------------------------------------------
func _apply_tiles_to_tilemap(tiles : Array):
	_terrain.clear()
	
	for x in WIDTH:
		for y in HEIGHT:
			if not Engine.editor_hint:
				_terrain.set_background(x, y)
			
			_terrain.set_cell(x, y, tiles[x][y])
	
	var buffer = 10
	
	for x in range(-buffer, WIDTH + buffer):
		for y in range(0, buffer):
			_terrain.set_cell(x, -1 - y, _terrain.TileType.Unbreakable)
			_terrain.set_cell(x, HEIGHT + y, _terrain.TileType.Unbreakable)
	
	for y in HEIGHT:
		for x in range(0, buffer):
			_terrain.set_cell(-1 - x, y, _terrain.TileType.Unbreakable)
			_terrain.set_cell(HEIGHT + x, y, _terrain.TileType.Unbreakable)
	
	_terrain.update_bitmask_region(Vector2(-buffer, -buffer), 
								   Vector2(WIDTH + buffer, HEIGHT + buffer))


# ------------------------------------------------------------------------------
func _ready():
	randomize()
	noise_seed = randi()
	
	var parent = get_parent()
	if parent != null and parent is Terrain:
		_terrain = parent
		generate_world()
	
	if Engine.editor_hint:
		call_deferred("clear")


# ------------------------------------------------------------------------------
