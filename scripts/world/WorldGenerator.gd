extends ProceduralGenerator
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
export(float, 0, 1, 0.001) var branch_threshold = 0.01 setget _set_branch_threshold
export(float, 0, 0.1, 0.001) var chance_to_branch = 0.01 setget _set_chance_to_branch
export(float, 0, 1, 0.001) var max_branch_rotation = 0.2 setget _set_max_branch_rotation

# Minerals
export(float, 0, 1, 0.001) var minerals_lower_threshold = 0.01 setget _set_minerals_lower_threshold
export(float, 0, 1, 0.001) var minerals_upper_threshold = 0.2 setget _set_minerals_upper_threshold
export(float, 0, 1, 0.001) var minerals_height_modifier_intensity = 0.2 setget _set_minerals_height_modifier_intensity

# Walls
export(int, 0, 100, 1) var wall_buffer = 5 setget _set_wall_buffer

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

var _terrain : Terrain = null


# ------------------------------------------------------------------------------
# Setter Methods
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
func _set_width(value : int) -> void:
	width = value
	_consider_regenerating()

# ------------------------------------------------------------------------------
func _set_cave_height(value : int) -> void:
	cave_height = value
	_consider_regenerating()

# ------------------------------------------------------------------------------
func _set_ground_height(value : int) -> void:
	ground_height = value
	_consider_regenerating()

# ------------------------------------------------------------------------------
func _set_min_caves(value : int) -> void:
	min_caves = value
	_consider_regenerating()

# ------------------------------------------------------------------------------
func _set_max_caves(value : int) -> void:
	if value >= min_caves:
		max_caves = value
		_consider_regenerating()

# ------------------------------------------------------------------------------
func _set_cave_movement_volatility(value : int) -> void:
	cave_movement_volatility = value
	_consider_regenerating()

# ------------------------------------------------------------------------------
func _set_min_main_cave_radius(value : int) -> void:
	min_main_cave_radius = value
	_consider_regenerating()

# ------------------------------------------------------------------------------
func _set_max_main_cave_radius(value : int) -> void:
	if value >= min_main_cave_radius:
		max_main_cave_radius = value
		_consider_regenerating()

# ------------------------------------------------------------------------------
func _set_min_branch_radius(value : int) -> void:
	min_branch_radius = value
	_consider_regenerating()

# ------------------------------------------------------------------------------
func _set_max_branch_radius(value : int) -> void:
	if value >= min_branch_radius:
		max_branch_radius = value
		_consider_regenerating()

# ------------------------------------------------------------------------------
func _set_chance_to_branch(value : float) -> void:
	chance_to_branch = value
	_consider_regenerating()

# ------------------------------------------------------------------------------
func _set_branch_threshold(value : float) -> void:
	branch_threshold = value
	_consider_regenerating()

# ------------------------------------------------------------------------------
func _set_max_branch_rotation(value : float) -> void:
	max_branch_rotation = value
	_consider_regenerating()

# ------------------------------------------------------------------------------
func _set_wall_buffer(value : int) -> void:
	wall_buffer = value
	_consider_regenerating()

# ------------------------------------------------------------------------------
func _set_minerals_lower_threshold(value : float) -> void:
	minerals_lower_threshold = value
	_consider_regenerating()
		
# ------------------------------------------------------------------------------
func _set_minerals_upper_threshold(value : float) -> void:
	minerals_upper_threshold = value
	_consider_regenerating()

func _set_minerals_height_modifier_intensity(value : float) -> void:
	minerals_height_modifier_intensity = value
	_consider_regenerating()

# ------------------------------------------------------------------------------
# Regular Methods
# ------------------------------------------------------------------------------
func _consider_regenerating():
	if Engine.editor_hint:
		generate()


# ------------------------------------------------------------------------------
func _get_noise_dict() -> Dictionary:
	return noise_list


# ------------------------------------------------------------------------------
func clear():
	if _are_tilemaps_valid():
		_background.clear()
		_foreground.clear()
		_details.clear()
		


# ------------------------------------------------------------------------------
func generate():
	if _are_tilemaps_valid():
		clear()
		apply_seed()
		
		var surface = _generate_ground_height()
		
		_fill_area(Vector2(0, ground_height), 
			Vector2(width, ground_height + cave_height), 0)
		
		_generate_caves(surface)
		_generate_minerals()
		_place_grass(surface)
		_place_borders()
		_update_autotiles()
		_set_camera_bounds()
		
	else:
		print("No tile maps could be found")


# ------------------------------------------------------------------------------
func _generate_ground_height():
	var surface = []
	
	# Loop across the width of the world.
	for x in width:
		
		# Decides the height for this x based on noise.
		var sample = noise_list.ground_height._noise.get_noise_1d(x)
		var ground_y = (sample + 1.0) * 0.5 * ground_height
		
		# Appends the ground height.
		surface.append(ground_y)
		
		# Fills in the ground from the ground height to the cave start.
		for y in range(ground_y, ground_height):
			_foreground.set_cell(x, y, 0)
	
	return surface


# ------------------------------------------------------------------------------
func _generate_caves(surface : Array):
	var cave_starts = _generate_cave_starts(surface)
	_generate_primary_caves(cave_starts, surface)


# ------------------------------------------------------------------------------
func _generate_cave_starts(surface : Array) -> Array:
	
	# Picks a number of caves and then divides the map width by the number.
	var number_of_caves = randi() % (max_caves + 1 - min_caves) + min_caves
	var division_size = width / (number_of_caves + 2)
	
	var cave_starts = []
	
	# Randomly chooses the start x of each cave in their own division.
	for i in range(1, number_of_caves + 1):
		var start = division_size * i
		var lowest = []
		
		# Orders all the x positions in the division by lowest surface height.
		for x in range(start, start + division_size):
			var found = false
			
			for j in lowest.size():
				if surface[x] > surface[lowest[j]]:
					lowest.insert(j, x)
					found = true
					break
					
			if not found:
				lowest.append(x)
		
		# Chooses a random position out of lowest quarter of the positions.
		cave_starts.append(lowest[randi() % int(division_size * 0.25)])
	
	return cave_starts


# ------------------------------------------------------------------------------
func _generate_primary_caves(cave_starts : Array, surface : Array) -> void:
	var one_over_ground_height = 1.0 / ground_height
	
	# Loops for each cave start.
	for start_x in cave_starts:
		var prev_x = start_x
		
		# Loops from the surface to the bottom of the world.
		for y in range(surface[start_x], ground_height + cave_height):
			
			 # Stops the caves moving so much when closer to the surface.
			var surface_modifier = min(y * one_over_ground_height, 1.0)
			
			# Picks the next x position using noise.
			var sample = noise_list.cave_horizontal._noise.get_noise_2d(start_x, y) 
			var next_x = start_x + sample * cave_movement_volatility * surface_modifier
			
			# Loops from the previous x to the next x and clears a path.
			for x in range(min(prev_x, next_x), max(prev_x, next_x) + 1):
				
				# Picks a radius using noise based on x, y position.
				var r_sample = noise_list.cave_radius._noise.get_noise_2d(x, y)
				var radius = max(abs(r_sample) * max_main_cave_radius, min_main_cave_radius)
				_clear_circle(x, y, radius, surface)
			
			# If not near the surface, randomly chooses to branch out.
			if y > ground_height:
				if abs(sample) <= branch_threshold and randf() <= chance_to_branch:
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
		
		# If approaching the surface, stops expanding.
		if round_y < ground_height:
			break
		
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
func _generate_minerals():
	var one_over_height = 1.0 / (cave_height + ground_height)
	for x in width:
		for y in range(cave_height + ground_height):
			
			if _foreground.get_cell(x, y) == 0:
				
				var sample = abs(noise_list.minerals._noise.get_noise_2d(x, y))
				var height_modifier = y * one_over_height * minerals_height_modifier_intensity
				sample = min(sample + height_modifier, 1)
				
				if (sample >= minerals_lower_threshold 
					and sample <= minerals_upper_threshold):
						_foreground.set_cell(x, y, 2)
	

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
func _get_edge_dist_modifier(x, y):
	var total_height = cave_height + ground_height
	
	var bottom = 1 - (min(total_height - y, EDGE_SOFTENING) / EDGE_SOFTENING)
	var left = 1 - (min(x, EDGE_SOFTENING) / EDGE_SOFTENING)
	var right = 1 - (min(width - x, EDGE_SOFTENING) / EDGE_SOFTENING)
	
	return (bottom + left + right) * 0.3


# ------------------------------------------------------------------------------
func _place_borders() -> void:
	var map_bottom = cave_height + ground_height
	
	for x in width:
		for y in range(map_bottom, map_bottom + wall_buffer):
			_foreground.set_cell(x, y, 1)
	
	for x in range(1, wall_buffer):
		for y in range(-wall_buffer, map_bottom + wall_buffer):
			_foreground.set_cell(-x, y, 1)
			_foreground.set_cell(width + x - 1, y, 1)
	

# ------------------------------------------------------------------------------
func _update_autotiles():
	_foreground.update_bitmask_region(Vector2(-wall_buffer, -wall_buffer), 
		Vector2(width + wall_buffer, cave_height + ground_height + wall_buffer))
		
		
# ------------------------------------------------------------------------------
func _set_camera_bounds():
	var cams = get_tree().get_nodes_in_group("main_camera")
	if cams and not cams.empty():
		var cam : Camera2D = cams.front()
		
		cam.limit_top = -100
		cam.limit_left = 0
		cam.limit_right = width * 16
		cam.limit_bottom = (cave_height + ground_height) * 16
		

# ------------------------------------------------------------------------------
func _ready():
	randomize()
	noise_seed = randi()
	
	if Engine.editor_hint:
		call_deferred("clear")

	elif _get_tilemaps():
		generate()
		_terrain.generate_pathfinding_grid(Vector2(-wall_buffer, -wall_buffer), 
			Vector2(width + wall_buffer, cave_height + ground_height + wall_buffer))


# ------------------------------------------------------------------------------
func _get_tilemaps() -> bool:
	var parent = get_parent()
	if parent != null and parent is Terrain:
		_terrain = parent
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
func _are_tilemaps_valid() -> bool:
	return ((_foreground != null and _background != null and _details != null) 
		or _get_tilemaps())


# ------------------------------------------------------------------------------
