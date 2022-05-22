extends Node2D

var _view_range_cells : int = 8

# Dependancies.
var _occlusion_map : TileMap = null
var _terrain : Terrain = null
 
# Constants.
const CELL_SIZE : float = 16.0
const RECALCULATE_DISTANCE : float = CELL_SIZE * 0.5
const RECALCULATE_DISTANCE_SQUARED : float = RECALCULATE_DISTANCE * RECALCULATE_DISTANCE
const INVALID_CELL : Vector2 = Vector2(-1000, -1000)

# Private variables.
var _view_range_cells_sq : int = _view_range_cells * _view_range_cells
var _last_check_pos : Vector2 = Vector2.ZERO
var _checked : Array = [] # Array<bool>
var _queue : Array = [] # Array<Vector2>
var _light_value = {}

var font = preload("res://resources/fonts/WorldHintFont.tres")


# ------------------------------------------------------------------------------
func _ready():
	_view_range_cells_sq = _view_range_cells * _view_range_cells
	
	var terrains = get_tree().get_nodes_in_group("terrain")
	if terrains and not terrains.empty():
		_terrain = terrains.front()
	
	var occlusions = get_tree().get_nodes_in_group("occlusion_map")
	if occlusions and not occlusions.empty():
		_occlusion_map = occlusions.front()
	
	_check_surroundings()


#-------------------------------------------------------------------------------
func _physics_process(_delta) -> void:
	var pos = global_position
	if (_last_check_pos - pos).length_squared() > RECALCULATE_DISTANCE_SQUARED:
		_last_check_pos = pos
		
		_check_surroundings()
		
	update()


#-------------------------------------------------------------------------------
func _check_surroundings() -> void:
	
	for cell in _checked:
		if _terrain.has_background(cell):
			_occlusion_map.set_cellv(cell, 0)
	
	_queue.clear()
	_checked.clear()
	_light_value.clear()
	
	var cell_pos = _terrain.world_to_map(global_position)
	_occlusion_map.set_cellv(cell_pos, -1)
	_queue.append(cell_pos)
	_checked.append(cell_pos)
	_light_value[cell_pos] = 0

	var my_cell_pos = _terrain.world_to_map(global_position)
	
	# Loops for every cell in the queue, popping the front each time.
	while not _queue.empty():
		var next_cell : Vector2 = _queue.pop_front()
		
		# If the cell is within range, checks all its neighbours.
		if _is_within_range(next_cell, my_cell_pos):
			_check_neighbours(next_cell)
	
	update()


#-------------------------------------------------------------------------------
func _check_neighbours(cell : Vector2) -> void:
	var previous : Vector2 = cell
	
	# Loop through all neighbours.
	for current in _get_neighbours(previous):
		
		# Checks the cell if it has not been checked already.
		if not _checked.has(current):

			if not _terrain.is_empty(current):
				var prev_cell_occlusion = _occlusion_map.get_cellv(previous)
				_occlusion_map.set_cellv(current, prev_cell_occlusion)

			else:
				# Checks that the cell is within line of sight. 
#				var dist = _terrain.map_to_world_centred(current) - global_position
#				$RayCast2D.cast_to = dist
#				$RayCast2D.force_raycast_update()
#
#				var occlusion_level = 1 if $RayCast2D.is_colliding() else -1
#				_occlusion_map.set_cellv(current, occlusion_level)
				_occlusion_map.set_cellv(current, -1)
				
				_light_value[current] = _light_value[previous] + 1
				_queue.append(current)
				
			_checked.append(current)

#-------------------------------------------------------------------------------
func _get_neighbours(cell : Vector2) -> Array:
	return [ 
		cell - Vector2(-1, 0),
		cell - Vector2(0, 1),
		cell - Vector2(1, 0),
		cell - Vector2(0, -1),
		
#		cell - Vector2(-1, -1),
#		cell - Vector2(-1, 1),
#		cell - Vector2(1, -1),
#		cell - Vector2(1, 1),
	]


#-------------------------------------------------------------------------------
func _is_within_range(cell_pos : Vector2, my_cell_pos : Vector2) -> bool:
	return ((cell_pos - my_cell_pos).length_squared() <= _view_range_cells_sq
		and _light_value[cell_pos] < _view_range_cells)


#-------------------------------------------------------------------------------
func _draw() -> void:
	if Utility.is_debug_mode():
		for cell in _queue:
			var global = _terrain.map_to_world_centred(cell)
			var local = global - global_position
			draw_circle(local, 5, Color.deeppink)
	
		for cell in _light_value.keys():
			var dist = _terrain.map_to_world_centred(cell) - global_position
			draw_string(font, dist, str(_light_value[cell]))
	
	
#-------------------------------------------------------------------------------
