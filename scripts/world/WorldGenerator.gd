extends ProceduralGenerator
signal world_generated(terrain_tiles)
tool

export(int, 0, 200, 2) var width = 100 setget _set_width
export(int, 0, 200, 2) var ground_height = 50 setget _set_ground_height
export(int, 0, 200, 2) var cave_height = 100 setget _set_cave_height

const EDGE_SOFTENING = 5
var _background : TileMap = null
var _foreground : TileMap = null
var _details : TileMap = null

var noise_list = {
	ground_height = Noise.new(),
	cave_horizontal = Noise.new(),
	cave_radius = Noise.new(),
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
		_background.clear()
		_foreground.clear()
		_details.clear()
		


# ------------------------------------------------------------------------------
func generate():
	
	if (_foreground != null and _background != null) or _get_tilemaps():
		
		clear()
		
		var tiles = []
		
		for x in width:
			tiles.append([])
			
			for y in cave_height + ground_height:
				tiles[x].append(0)
		
		apply_seed()
		
		var surface = _generate_ground_height()
		
		_fill_area(Vector2(0, ground_height), 
			Vector2(width, ground_height + cave_height), 0)
			
		_generate_caves(surface)
		_place_grass(surface)
		
		emit_signal("world_generated", tiles)
		_update_autotiles()
	else:
		print("No tiles")


# ------------------------------------------------------------------------------
func _generate_ground_height():
	var surface = []
	
	for x in width:
		var sample = noise_list.ground_height._noise.get_noise_1d(x)
		var ground_y = (sample + 1.0) * 0.5 * ground_height
		
		surface.append(ground_y)
		
		for y in range(ground_y, ground_height):
			_foreground.set_cell(x, y, 0)
	
	return surface


# ------------------------------------------------------------------------------
func _generate_caves(surface : Array):
	var caves_max = 5
	var caves_min = 3
	
	var caves = randi() % (caves_max - caves_min) + caves_min
	
	for i in caves:
		var prev_x = randi() % width
	
		for y in range(surface[prev_x], ground_height + cave_height):
			var next_x = prev_x + noise_list.cave_horizontal._noise.get_noise_2d(prev_x, y) * 10
			
			for x in range(min(prev_x, next_x), max(prev_x, next_x) + 1):
				var sample = noise_list.cave_radius._noise.get_noise_2d(x, y)
				var radius = (sample + 1) * 3
				_clear_circle(x, y, radius, surface)
			
			prev_x = next_x


# ------------------------------------------------------------------------------
func _clear_circle(start_x, start_y, radius : int, surface : Array):
	for x in range(-radius, radius + 1):
		
		# Uses the circle formula to get the max y.
		var max_y = sqrt((radius * radius) - (x * x))
		
		for y in range(-max_y, max_y + 1):
			var new_x = start_x + x
			var new_y = start_y + y
			
			if (new_x >= 0 and new_x < width 
				and new_y >= surface[new_x] - 1 and new_y < ground_height + cave_height):
					_foreground.set_cell(new_x, new_y, -1)
					_background.set_cell(new_x, new_y, 0)


# ------------------------------------------------------------------------------
func _place_grass(surface : Array):
	for x in surface.size():
		var y = surface[x]
		if _foreground.get_cell(x, y) == 0:
			_details.set_cell(x, y - 1, randi() % 2)
	
	
# ------------------------------------------------------------------------------
func _fill_area(top_left : Vector2, bottom_right: Vector2, value : int) -> void:
	for x in range(top_left.x, bottom_right.x):
		for y in range(top_left.y, bottom_right.y):
			_foreground.set_cell(x, y, value)


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
func _update_autotiles():
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
		_background = parent.get_node("Background")
		_foreground = parent.get_node("Foreground")
		_details = parent.get_node("Details")
		return _foreground and _background
	else:
		print_debug("No terrain parent")
	return false
	
	
# ------------------------------------------------------------------------------
func apply_seed():
	for noise in noise_list.values():
		noise._noise.seed = noise_seed
	
	seed(noise_seed)
	
	
# ------------------------------------------------------------------------------
