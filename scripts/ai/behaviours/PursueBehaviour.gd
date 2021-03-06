class_name PursueBehaviour
extends Behaviour

signal target_reached()


const _IDEAL_DISTANCE_SQUARED = 4.0 * 4.0

var _terrain : Terrain = null
var _pathfinding : AStar2D = null

var _cell_size : Vector2 = Vector2.ZERO
var _cell_size_squared : float = 0.0
var _path : PoolIntArray
var _last_target : Vector2 = Vector2.ZERO
var _disable_when_goal_reached = true
var _entity_avoider = null


#---------------------------------------------------------------------------
func _init(disable_when_goal_reached = true):
	_name = "PursueBehaviour"
	_disable_when_goal_reached = disable_when_goal_reached
	
	
#-------------------------------------------------------------------------------
func _ready() -> void:
	var terrain_container = get_tree().get_nodes_in_group("terrain")
	if not terrain_container.empty():
		_terrain = terrain_container.front()
		_pathfinding = _terrain.get_pathfinding()
		_cell_size = _terrain.get_cell_size()
		_cell_size_squared = _cell_size.length_squared()
		
		_entity_avoider = _brain.find_node("EntityAvoider")
		

#-------------------------------------------------------------------------------
func _process(delta : float) -> void:
	if _active:
		var target = _brain.get_target()
		var found_new_path = false
		
		# If the target has changed since last time, regenerates the path.
		if _path == null or _path.size() <= 1 or target != _last_target:
			_last_target = target
			_find_new_path()
			found_new_path = true
		
		if not _entity_avoider.get_entities_to_avoid().empty():
			_find_new_path()
			found_new_path = true
			
		if _path and _path.size() > 1:
			
			# If a new path has not just been found and we're not within range 
			#	of the path.
			if not found_new_path and not _is_within_range_of_path():
				_find_new_path()
				found_new_path = true
				
				# If the new path is valid.
				if _path and _path.size() > 1:
					_follow_path(delta)
			else:
				_follow_path(delta)
		else:
			if _disable_when_goal_reached:
				set_active(false)
				
			_brain.subject.direction = 0.0
			emit_signal("target_reached")
			
	update()


#-------------------------------------------------------------------------------
func _find_new_path():
	
	# Temporarily disables any points blocked by nearby entities.
	var point_ids = []
	var entities = _entity_avoider.get_entities_to_avoid()
	if not entities.empty():
		for entity in entities:
			
			var cell = _terrain.world_to_map(entity.global_position)
			if _terrain.is_empty(cell):
				var point = _pathfinding.get_closest_point(entity.global_position, true)
				
				_pathfinding.set_point_disabled(point, true)
				point_ids.append(point)
	
	# Finds a new path.
	var subject_point = _pathfinding.get_closest_point(_brain.subject.position)
	var target_point = _pathfinding.get_closest_point(_brain.get_target())
	if subject_point != -1 and target_point != -1:
		_path = _pathfinding.get_id_path(subject_point, target_point)
	
	# Enables any disabled points.
	if not point_ids.empty():
		for point in point_ids:
			_pathfinding.set_point_disabled(point, false)


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
	var diff = pos.x - _brain.subject.global_position.x
	
	if abs(diff) > 5.0:
		_brain.subject.direction = sign(diff)
	else:
		_brain.subject.direction = 0
	
	_brain.set_hover(true)
	if pos.y + 5.0 < _brain.subject.position.y:
		_brain.subject.jump(delta)
	else:
		_brain.set_hover(false)


#-------------------------------------------------------------------------------
func _draw():
	if _brain.is_debug() and _active:
		for node in _path:
			var dist = _pathfinding.get_point_position(node) - _brain.subject.position
			draw_circle(dist, 2, Color.red)

		var dist = _brain.subject.get_target() - _brain.subject.position
		draw_circle(dist, 2, Color.red)

		
#-------------------------------------------------------------------------------
