extends Node2D

signal new_furthest(furthest_cell)


var _terrain : Terrain = null

const CELL_SIZE : float = 16.0
const RECALCULATE_DISTANCE : float = CELL_SIZE * 3.0
const RECALCULATE_DISTANCE_SQUARED : float = RECALCULATE_DISTANCE * RECALCULATE_DISTANCE
 
var view_range_cells_squared : int = 8 * 8

var _last_checked_location : Vector2 = Vector2.ZERO

# Vector2 : bool
var _checked : Array = []
var _queue = [] # Vector2

var _furthest_cell : Vector2 = Vector2.ZERO
var _furthest_dist_squared : float = 0.0


#-------------------------------------------------------------------------------
func _ready():
	var terrain_container = get_tree().get_nodes_in_group("terrain")
	if not terrain_container.empty():
		_terrain = terrain_container.front()
	
		var cell_pos = _terrain.world_to_map(global_position)
		_furthest_cell = cell_pos
		_queue.append(cell_pos)
		_check_surroundings()


#-------------------------------------------------------------------------------
func _physics_process(_delta):
	if (_last_checked_location - global_position).length_squared() > RECALCULATE_DISTANCE_SQUARED:
		_last_checked_location = global_position
		_check_surroundings()
		
	update()


#-------------------------------------------------------------------------------
func _check_surroundings():
	var previous_furthest = _furthest_cell
	
	var cell_pos = _terrain.world_to_map(global_position)
	var next_queue = []
	
	# Re-assesses the furthest cell.
	var dist_squared = (_furthest_cell - cell_pos).length_squared()
	_furthest_dist_squared = dist_squared
	
	while not _queue.empty():
		
		var node : Vector2 = _queue.pop_front()
		
		# If the cell is within range.
		if (node - cell_pos).length_squared() <= view_range_cells_squared:
			
			# Check all neighbours and check it's checked.
			for neighbour in _get_neighbours(node):
				
				# If the cell has not been check.
				if not _checked.has(neighbour):
					_checked.append(neighbour)
					
					# If the cell is an empty cell, proceed.
					if _terrain.is_empty(neighbour):
						_queue.append(neighbour)
						
						dist_squared = (neighbour - cell_pos).length_squared()
						if dist_squared > _furthest_dist_squared:
							_furthest_dist_squared = dist_squared
							_furthest_cell = neighbour
		
		else:
			next_queue.append(node)
		
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
func _draw():
	for cell in _queue:
		var global = _terrain.map_to_world_centred(cell)
		var local = global - global_position
		draw_circle(local, 5, Color.blue)
		
		
#-------------------------------------------------------------------------------
