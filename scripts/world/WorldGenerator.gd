extends Node2D
signal world_generated(terrain_tiles)
tool


class Noise:
	var _noise = OpenSimplexNoise.new()
	var _params = {
		"octaves": 4,
		"period": 5.076,
		"lacunarity": 0.731,
		"persistence": 1.67,
		"split": 0.489,
		"sign": true,
	}
	
	var _properies = [
			{ name = "octaves", hint = PROPERTY_HINT_RANGE, hint_string = "1,9,1", type = TYPE_REAL },
			{ name = "period", hint = PROPERTY_HINT_RANGE, hint_string = "0,500", type = TYPE_REAL },
			{ name = "lacunarity", hint = PROPERTY_HINT_RANGE, hint_string = "0,5", type = TYPE_REAL },
			{ name = "persistence", hint = PROPERTY_HINT_RANGE, hint_string = "0,5", type = TYPE_REAL },
			{ name = "split", hint = PROPERTY_HINT_RANGE, hint_string = "0,1", type = TYPE_REAL },
			{ name = "sign", type = TYPE_BOOL },
		]
	
	func _get_property_list():
		return _properies
	
	func _set(property, value):
		if _params.has(property):
			_params[property] = value
			
			if property != "split" and property != "sign":
				_noise.set(property, value)
	
	func _get(property):
		if _params.has(property):
			return _params[property]

var noise_list = {
	cave = Noise.new(),
	minerals = Noise.new(),
	ground_height = Noise.new(),
}

const WIDTH = 100
const HEIGHT = 100
const EDGE_SOFTENING = 5
var noise_seed = randi()
var _foreground : TileMap = null
var _background : TileMap = null


func _get_property_list():
	var props = [
		{ name = "randomize_seed", type = TYPE_BOOL },
		{ name = "clear", type = TYPE_BOOL },
	]

	for noise_name in noise_list.keys():
		var p_list = noise_list[noise_name].get_property_list()

		for p in p_list:
			props.append(p)
			props.back().name = noise_name + "/" + props.back().name

	return props
	



# ------------------------------------------------------------------------------
func _set(property : String, value):
	var split = property.split("/")

	if split.size() == 2:
		var noise_name = property.split("/")[0]
		var prop_name = property.split("/")[1]

		if noise_list.has(noise_name):
			noise_list[noise_name]._set(prop_name, value)
		
		generate_world()
		
	elif Engine.editor_hint: 
		if property == "randomize_seed":
			noise_seed = randi()
			generate_world()

		elif property == "clear":
			clear()

		else:
			generate_world()


# ------------------------------------------------------------------------------
func _get(property):
	var split = property.split("/")

	if split.size() == 2:
		var noise_name = property.split("/")[0]
		var prop_name = property.split("/")[1]

		if noise_list.has(noise_name):
			return noise_list[noise_name]._get(prop_name)


# ------------------------------------------------------------------------------
func clear():
	if _foreground != null:
		_foreground.clear()
		_background.clear()


# ------------------------------------------------------------------------------
func generate_world():
	
	if _foreground != null or _get_tilemaps():
		
		var tiles = []
		noise_list.cave._noise.seed = noise_seed
		noise_list.minerals._noise.seed = noise_seed
		
		for x in WIDTH:
			tiles.append([])
			
			for y in HEIGHT:	
				var noise_sample = noise_list.cave._noise.get_noise_2d(x, y)
				var normalised_sample = (noise_sample + 1.0) * 0.5
				normalised_sample = min(normalised_sample 
					+ _get_edge_dist_modifier(x, y), 1)
				
				tiles[x].append(_get_tile_from_height(normalised_sample))
				
				if 0 == tiles[x][y]:
					noise_sample = noise_list.minerals._noise.get_noise_2d(float(x), float(y))
					tiles[x][y] = _get_tile_from_mineral(noise_sample)
		
		emit_signal("world_generated", tiles)
		_apply_tiles_to_tilemap(tiles)
	else:
		print("No tiles")


# ------------------------------------------------------------------------------
func _get_tile_from_height(noise_sample):
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
	var top = 1 - (min(y, EDGE_SOFTENING) / EDGE_SOFTENING)
	var bottom = 1 - (min(HEIGHT - y, EDGE_SOFTENING) / EDGE_SOFTENING)
	var left = 1 - (min(x, EDGE_SOFTENING) / EDGE_SOFTENING)
	var right = 1 - (min(WIDTH - x, EDGE_SOFTENING) / EDGE_SOFTENING)
	return (top + bottom + left + right) / 2.0 * 0.3


# ------------------------------------------------------------------------------
func _apply_tiles_to_tilemap(tiles : Array):
	clear()
	
	for x in WIDTH:
		for y in HEIGHT:
			_background.set_cellv(Vector2(x, y), 0)
			_foreground.set_cell(x, y, tiles[x][y])
	
	var buffer = 10
	
	for x in range(-buffer, WIDTH + buffer):
		for y in range(0, buffer):
			_foreground.set_cell(x, -1 - y, 1)
			_foreground.set_cell(x, HEIGHT + y, 1)
	
	for y in HEIGHT:
		for x in range(0, buffer):
			_foreground.set_cell(-1 - x, y, 1)
			_foreground.set_cell(HEIGHT + x, y, 1)
	
	_foreground.update_bitmask_region(Vector2(-buffer, -buffer), 
								   Vector2(WIDTH + buffer, HEIGHT + buffer))


# ------------------------------------------------------------------------------
func _ready():
	randomize()
	noise_seed = randi()
	
	if Engine.editor_hint:
		call_deferred("clear")

	elif _get_tilemaps():
		generate_world()


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
