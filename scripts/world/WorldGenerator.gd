extends ProceduralGenerator
signal world_generated(terrain_tiles)
tool

export(int, 0, 200, 2) var width = 100 setget _set_width
export(int, 0, 200, 2) var ground_height = 50 setget _set_ground_height

# Caves
export(int, 0, 500, 2) var cave_height = 100 setget _set_cave_height
export(int, 1, 10, 1) var min_caves = 3 setget _set_min_caves
export(int, 1, 10, 1) var max_caves = 5 setget _set_max_caves
export(int, 1, 50, 2) var cave_movement_volatility = 5 setget _set_cave_movement_volatility
export(int, 1, 20, 1) var min_main_cave_radius = 2 setget _set_min_main_cave_radius
export(int, 1, 20, 1) var max_main_cave_radius = 5 setget _set_max_main_cave_radius

# Branches
export(int, 1, 20, 1) var min_branch_radius = 2 setget _set_min_branch_radius
export(int, 1, 20, 1) var max_branch_radius = 5 setget _set_max_branch_radius
export(float, 0, 0.1, 0.001) var chance_to_branch = 0.01 setget _set_chance_to_branch
export(float, 0, 1, 0.001) var max_branch_rotation = 0.2 setget _set_max_branch_rotation

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
# Setter Methods
# ------------------------------------------------------------------------------

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
func _set_min_caves(value : int) -> void:
	min_caves = value
	
	if Engine.editor_hint:
		generate()


# ------------------------------------------------------------------------------
func _set_max_caves(value : int) -> void:
	if value >= min_caves:
		max_caves = value
		
		if Engine.editor_hint:
			generate()


# ------------------------------------------------------------------------------
func _set_cave_movement_volatility(value : int) -> void:
	cave_movement_volatility = value
		
	if Engine.editor_hint:
		generate()


# ------------------------------------------------------------------------------
func _set_min_main_cave_radius(value : int) -> void:
	min_main_cave_radius = value
		
	if Engine.editor_hint:
		generate()


# ------------------------------------------------------------------------------
func _set_max_main_cave_radius(value : int) -> void:
	if value >= min_main_cave_radius:
		max_main_cave_radius = value
			
		if Engine.editor_hint:
			generate()


# ------------------------------------------------------------------------------
func _set_min_branch_radius(value : int) -> void:
	min_branch_radius = value
	
	if Engine.editor_hint:
			generate()


# ------------------------------------------------------------------------------
func _set_max_branch_radius(value : int) -> void:
	if value >= min_branch_radius:
		max_branch_radius = value
		
		if Engine.editor_hint:
				generate()


# ------------------------------------------------------------------------------
func _set_chance_to_branch(value : float) -> void:
	chance_to_branch = value
	
	if Engine.editor_hint:
		generate()


# ------------------------------------------------------------------------------
func _set_max_branch_rotation(value : float) -> void:
	max_branch_rotation = value
	
	if Engine.editor_hint:
		generate()


# ------------------------------------------------------------------------------
# Regular Methods
# ------------------------------------------------------------------------------

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
	# Picks a number of caves and then divides the map width by the number.
	var number_of_caves = randi() % (max_caves + 1 - min_caves) + min_caves
	var division_size = width / (number_of_caves + 2)
	
	var cave_starts = []
	
	# Randomly chooses the start x of each cave in their own division.
	for i in range(1, number_of_caves + 1):
		cave_starts.append(randi() % division_size + division_size * i)
	
	# Loops for each cave start.
	for prev_x in cave_starts:
		
		for y in range(surface[prev_x], ground_height + cave_height):
			
			var change = (noise_list.cave_horizontal._noise.get_noise_2d(prev_x, y) 
				* cave_movement_volatility)
				
			var next_x = prev_x + change
			if next_x < 0 or change >= width:
				next_x = prev_x - change
			
			for x in range(min(prev_x, next_x), max(prev_x, next_x) + 1):
				var sample = noise_list.cave_radius._noise.get_noise_2d(x, y)
				var radius = max(abs(sample) * max_main_cave_radius, min_main_cave_radius)
				_clear_circle(x, y, radius, surface)
				
			if randf() <= chance_to_branch:
				_generate_secondary_cave(prev_x, y, surface)
			
			prev_x = next_x



# ------------------------------------------------------------------------------
func _generate_secondary_cave(x, y, surface : Array):
	var distance = randi() % 100
	var direction = Vector2.LEFT if randi() % 2 == 0 else Vector2.RIGHT
	
	var prev_round_x = int(x)
	var prev_round_y = int(y)
	
	var nodes = []
	
	for i in distance:
		var round_x = int(x)
		var round_y = int(y)
		
		if prev_round_x != round_x or prev_round_y != round_y:
			if _foreground.get_cell(round_x, round_y) != -1:
				nodes.append(Vector2(round_x, round_y))
				
			prev_round_x = round_x
			prev_round_y = round_y
		
		x += direction.x
		y += direction.y
		
		var sample = noise_list.cave_horizontal._noise.get_noise_2d(round_x, round_y)
		direction = direction.rotated(sample * PI * max_branch_rotation)

	for node in nodes:
		var sample = noise_list.cave_radius._noise.get_noise_2d(node.x, node.y)
		var radius = max(abs(sample) * max_branch_radius, min_branch_radius)
		_clear_circle(node.x, node.y, radius, surface)
		
		if randf() <= chance_to_branch:
			_generate_secondary_cave(x, y, surface)
		

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
	var split = 0.5
	
	if normalised_sample > split:
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
