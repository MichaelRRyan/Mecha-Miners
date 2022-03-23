extends Node2D

signal new_furthest(furthest_cell)

# Dependancies.
var _terrain : Terrain = null
 
# Public variables.
var view_range_cells : int = 8 setget set_view_range_cells

# Constants.
const CELL_SIZE : float = 16.0
const RECALCULATE_DISTANCE : float = CELL_SIZE * 3.0
const RECALCULATE_DISTANCE_SQUARED : float = RECALCULATE_DISTANCE * RECALCULATE_DISTANCE

# Private variables
var _view_range_cells_sq : int = view_range_cells * view_range_cells
var _last_check_pos : Vector2 = Vector2.ZERO
var _furthest_cell : Vector2 = Vector2.ZERO
var _checked : Array = [] # Array<bool>
var _queue : Array = [] # Array<Vector2>


#-------------------------------------------------------------------------------
func get_next_best() -> Vector2:
	if not _queue.empty():
		return _queue.front()	
	return Vector2.ZERO	


#-------------------------------------------------------------------------------
func set_view_range_cells(value : int) -> void:
	view_range_cells = value
	_view_range_cells_sq = value * value


#-------------------------------------------------------------------------------
func _ready() -> void:
	var terrain_container = get_tree().get_nodes_in_group("terrain")
	if not terrain_container.empty():
		_terrain = terrain_container.front()
	
		var cell_pos = _terrain.world_to_map(global_position)
		_furthest_cell = cell_pos
		_queue.append(cell_pos)
		_check_surroundings()


#-------------------------------------------------------------------------------
func _physics_process(_delta) -> void:
	if (_last_check_pos - global_position).length_squared() > RECALCULATE_DISTANCE_SQUARED:
		_last_check_pos = global_position
		_check_surroundings()
		
	update()


#-------------------------------------------------------------------------------
func _check_surroundings() -> void:
	
	var next_queue = []
	var previous_furthest = _furthest_cell
	var my_cell_pos = _terrain.world_to_map(global_position)
	
	# Assesses the furthest cell is still within range and returns the distance.
	var furthest_dist_sq = _assess_furthest_cell(my_cell_pos)
	
	# Loops for every cell in the queue, popping the top each time.
	while not _queue.empty():
		var next_cell : Vector2 = _queue.pop_front()
		
		# If the cell is within range, checks all its neighbours.
		if _is_within_range(next_cell, my_cell_pos):
			furthest_dist_sq = _check_neighbours(next_cell, my_cell_pos, furthest_dist_sq)
			
		# If the cell is outside the range, adds it to the next queue.
		else: next_queue.append(next_cell)
		
	_queue = next_queue
	
	if previous_furthest != _furthest_cell:
		emit_signal("new_furthest", _furthest_cell)


#-------------------------------------------------------------------------------
func _get_neighbours(cell : Vector2) -> Array:
	return [ 
		cell - Vector2(-1, 0),
		cell - Vector2(0, 1),
		cell - Vector2(1, 0),
		cell - Vector2(0, -1),
	]


#-------------------------------------------------------------------------------
func _is_within_range(cell_pos : Vector2, my_cell_pos : Vector2) -> bool:
	return (cell_pos - my_cell_pos).length_squared() <= _view_range_cells_sq


#-------------------------------------------------------------------------------
func _check_neighbours(next_cell : Vector2, my_cell_pos : Vector2, 
					   furthest_dist_squared : float) -> float:
						
	# Loop through all neighbours.
	for neighbour in _get_neighbours(next_cell):
		
		# Checks the cell if it has not been checked already.
		if not _checked.has(neighbour):
			_checked.append(neighbour)
			
			# If the cell is an empty cell, proceeds.
			if _terrain.is_empty(neighbour):
				_queue.append(neighbour)
				
				# Sets the cell as the new furthest cell if its distance is 
				#	greater than the previous furthest.
				var dist_squared = (neighbour - my_cell_pos).length_squared()
				if dist_squared > furthest_dist_squared:
					furthest_dist_squared = dist_squared
					_furthest_cell = neighbour
	
	return furthest_dist_squared


#-------------------------------------------------------------------------------
# Assesses the furthest cell is still within range and returns the distance.
func _assess_furthest_cell(my_cell_pos : Vector2) -> float:
	
	var dist_squared = (_furthest_cell - my_cell_pos).length_squared()
	
	# Checks the furthest cell is still within range.
	if dist_squared <= _view_range_cells_sq:
		return dist_squared
	else:
		_furthest_cell = Vector2.ZERO
		return 0.0
	

#-------------------------------------------------------------------------------
func _draw() -> void:
	for cell in _queue:
		var global = _terrain.map_to_world_centred(cell)
		var local = global - global_position
		draw_circle(local, 5, Color.blue)
		
		
#-------------------------------------------------------------------------------
