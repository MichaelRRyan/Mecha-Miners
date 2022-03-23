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
var _best_cell : Vector2 = Vector2.ZERO
var _checked : Array = [] # Array<bool>
var _queue : Array = [] # Array<Vector2>


#-------------------------------------------------------------------------------
func get_best_cell() -> Vector2:
	return _best_cell


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
		_best_cell = cell_pos
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
	var previous_best = _best_cell
	var my_cell_pos = _terrain.world_to_map(global_position)
	
	# Reassesses the furthest cell is still within range and returns the distance.
	var best_value = _reassess_furthest_cell(my_cell_pos)
	
	# Loops for every cell in the queue, popping the front each time.
	while not _queue.empty():
		var next_cell : Vector2 = _queue.pop_front()
		
		# If the cell is within range, checks all its neighbours.
		if _is_within_range(next_cell, my_cell_pos):
			best_value = _check_neighbours(next_cell, my_cell_pos, best_value)
			
		# If the cell is outside the range, adds it to the next queue.
		else: next_queue.append(next_cell)
		
	_queue = next_queue
	
	if previous_best != _best_cell:
		emit_signal("new_furthest", _best_cell)


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
					   best_value : float) -> float:
						
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
				var cell_value = _evaluate_cell(neighbour) + dist_squared
				
				if cell_value > best_value:
					best_value = cell_value
					_best_cell = neighbour
	
	return best_value


#-------------------------------------------------------------------------------
# Assesses the furthest cell is still within range and returns the distance.
func _reassess_furthest_cell(my_cell_pos : Vector2) -> float:
	
	var dist_squared = (_best_cell - my_cell_pos).length_squared()
	
	# Checks the furthest cell is still within range.
	if dist_squared <= _view_range_cells_sq:
		var cell_value = _evaluate_cell(_best_cell) + dist_squared
		return cell_value
	else:
		_best_cell = Vector2.ZERO
		return 0.0
	
	
#-------------------------------------------------------------------------------
func _evaluate_cell(cell_pos : Vector2) -> int:
	var dir = Vector2.DOWN
	var value_vec = cell_pos * dir
	var value = value_vec.x + value_vec.y
	return value * 10.0

#-------------------------------------------------------------------------------
func _draw() -> void:
	for cell in _queue:
		var global = _terrain.map_to_world_centred(cell)
		var local = global - global_position
		draw_circle(local, 5, Color.blue)
		
		
#-------------------------------------------------------------------------------
