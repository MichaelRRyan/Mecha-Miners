class_name FleeBehaviour
extends Behaviour

# Dependancies.
var _terrain : Terrain = null
var _threat_detector = null
 
# Constants.
const CELL_SIZE : float = 16.0
const RECALCULATE_DISTANCE : float = CELL_SIZE * 3.0
const RECALCULATE_DISTANCE_SQUARED : float = RECALCULATE_DISTANCE * RECALCULATE_DISTANCE
const INVALID_CELL : Vector2 = Vector2(-1000, -1000)

# Private variables.
var _view_range_cells_sq : int = 8 * 8
var _last_check_pos : Vector2 = Vector2.ZERO
var _checked : Array = [] # Array<bool>
var _queue : Array = [] # Array<Vector2>


#-------------------------------------------------------------------------------
func _init():
	_name = "FleeBehaviour"
	_priority = 6


# ------------------------------------------------------------------------------
func _ready():
	var spatial_sensor = _brain.find_node("SpatialSensor")
	if spatial_sensor != null:
		var view_range = spatial_sensor.view_range_cells
		_view_range_cells_sq = view_range * view_range
	
	_threat_detector = _brain.find_node("ThreatDetector")
	
	var terrains = get_tree().get_nodes_in_group("terrain")
	if terrains and not terrains.empty():
		_terrain = terrains.front()
	
	if _threat_detector == null or _terrain == null:
		_brain.pop_behaviour()
		return
	
	var cell_pos = _terrain.world_to_map(_brain.subject.global_position)
	_queue.append(cell_pos)
	_check_surroundings()
	
	_add_sub_behaviour(PursueBehaviour.new(false))


# ------------------------------------------------------------------------------
func _process(_delta):
	if _active and _threat_detector.get_threats().empty():
		_brain.pop_behaviour()


#-------------------------------------------------------------------------------
func _physics_process(_delta) -> void:
	var pos = _brain.subject.global_position
	if (_last_check_pos - pos).length_squared() > RECALCULATE_DISTANCE_SQUARED:
		_last_check_pos = pos
		
		_check_surroundings()
		
	update()


#-------------------------------------------------------------------------------
func _check_surroundings() -> void:
	
	var next_queue = []
	var previous_best = _queue.front()
	var my_cell_pos = _terrain.world_to_map(global_position)
	
	# Loops for every cell in the queue, popping the front each time.
	while not _queue.empty():
		var next_cell : Vector2 = _queue.pop_front()
		
		# If the cell is within range, checks all its neighbours.
		if _is_within_range(next_cell, my_cell_pos):
			_check_neighbours(next_cell)
			
		# If the cell is outside the range, adds it to the next queue.
		else: _sorted_add(next_cell, next_queue)
		
	_queue = next_queue
	
	var new_best = _queue.front()
	if new_best != null and previous_best != new_best:
		_brain.set_target(_terrain.map_to_world_centred(new_best))


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
func _check_neighbours(next_cell : Vector2) -> void:
						
	# Loop through all neighbours.
	for neighbour in _get_neighbours(next_cell):
		
		# Checks the cell if it has not been checked already.
		if not _checked.has(neighbour):
			_checked.append(neighbour)
			
			# If the cell is an empty cell, proceeds.
			if _terrain.is_empty(neighbour):
				_queue.append(neighbour)
	
	
#-------------------------------------------------------------------------------
func _evaluate_cell(cell_pos : Vector2) -> int:
	var world_pos = _terrain.map_to_world_centred(cell_pos)
	var my_pos = _brain.subject.global_position
	var eval_pos = my_pos + (world_pos - my_pos).normalized()
	
	var total_distance = 0
	
	var threats = _threat_detector.get_threats()
	for threat in threats:
		
		var dist = eval_pos - threat.global_position
		total_distance += dist.length_squared()
	
	return total_distance


#-------------------------------------------------------------------------------
func _sorted_add(cell_pos : Vector2, queue : Array) -> void:
	if queue.empty():
		queue.append(cell_pos)
		
	else:
		var start : int = 0
		var end : int = queue.size()
		var value : float = _evaluate_cell(cell_pos)
		
		while start < end - 1:
			var half = (end - start) * 0.5
			var index = start + half
			
			if value > _evaluate_cell(queue[index]):
				end -= half
			else:
				start += half
		
		if value >= _evaluate_cell(queue[start]):
			queue.insert(start, cell_pos)
		else:
			queue.insert(start + 1, cell_pos)


#-------------------------------------------------------------------------------
func _draw() -> void:
	if _brain.is_debug():
		for cell in _queue:
			var global = _terrain.map_to_world_centred(cell)
			var local = global - global_position
			draw_circle(local, 5, Color.deeppink)
		
		
#-------------------------------------------------------------------------------
