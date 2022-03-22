class_name PursueBehaviour
extends Behaviour

signal target_reached()


const _IDEAL_DISTANCE_SQUARED = 4.0 * 4.0

var _pathfinding : AStar2D = null

var _cell_size : Vector2 = Vector2.ZERO
var _cell_size_squared : float = 0.0
var _path : PoolIntArray
var _last_target : Vector2 = Vector2.ZERO


#---------------------------------------------------------------------------
func _init():
	_name = "PursueBehaviour"
	
	
#-------------------------------------------------------------------------------
func _ready() -> void:
	var terrain_container = get_tree().get_nodes_in_group("terrain")
	if not terrain_container.empty():
		var terrain = terrain_container.front()
		_pathfinding = terrain.get_pathfinding()
		_cell_size = terrain.get_cell_size()
		_cell_size_squared = _cell_size.length_squared()
		

#-------------------------------------------------------------------------------
func _process(delta : float) -> void:
	if _active:
		var target = _brain.get_target()
		var found_new_path = false
		
		# If the target has changed since last time, regenerates the path.
		if target != _last_target:
			_last_target = target
			_find_new_path()
			found_new_path = true
			
		if _path and _path.size() > 1:
			
			# If a new path has not just been found and we're not within range 
			#	of the path.
			if not found_new_path and not _is_within_range_of_path():
				_find_new_path()
				found_new_path = true
			
			_follow_path(delta)
			
		else:
			_brain.subject.direction = 0.0
			_brain.pop_behaviour()
			emit_signal("target_reached")
			
		update()

		
#-------------------------------------------------------------------------------
func _find_new_path():
	var subject_point = _pathfinding.get_closest_point(_brain.subject.position)
	var target_point = _pathfinding.get_closest_point(_brain.get_target())
	_path = _pathfinding.get_id_path(subject_point, target_point)


#-------------------------------------------------------------------------------
func _is_within_range_of_path():
	# Checks if we're too far from the first path node.
	var path_start = _pathfinding.get_point_position(_path[0])
	var dist_squared = (path_start - _brain.subject.position).length_squared()
	
	return dist_squared <= _cell_size_squared


#-------------------------------------------------------------------------------
func _follow_path(delta : float):
	var next_pos = _pathfinding.get_point_position(_path[1])
	var dist_squared = (next_pos - _brain.subject.position).length_squared()
	
	if _path.size() == 2:
		if dist_squared < _cell_size_squared * 0.1:
			_path.remove(0)
			
	elif dist_squared < _cell_size_squared:
		_path.remove(0)
	
	if _path.size() > 1:
		next_pos = _pathfinding.get_point_position(_path[1])
		_move_towards(next_pos, delta)


#-------------------------------------------------------------------------------
func _move_towards(pos : Vector2, delta : float) -> void:
	_brain.subject.direction = sign(pos.x - _brain.subject.position.x)
			
	if pos.y < _brain.subject.position.y:
		_brain.subject.thrust_jetpack(delta)
		
		
#-------------------------------------------------------------------------------
func _draw():
	for node in _path:
		var dist = _pathfinding.get_point_position(node) - _brain.subject.position
		draw_circle(dist, 2, Color.red)

	var dist = _brain.subject.get_target() - _brain.subject.position
	draw_circle(dist, 2, Color.red)

		
#-------------------------------------------------------------------------------
