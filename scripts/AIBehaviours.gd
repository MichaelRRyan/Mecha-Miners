extends Node
class_name AIBehaviours

#---------------------------------------------------------------------------
#-------------------------------------------------------------------------------
class Behaviour:
	extends Node
	
	var _brain = null setget set_brain
	
	#---------------------------------------------------------------------------
	func set_brain(brain) -> void:
		_brain = brain
	
	
	#---------------------------------------------------------------------------
	func _process(_delta : float) -> void:
		pass


#---------------------------------------------------------------------------
#-------------------------------------------------------------------------------
class IdleBehaviour:
	extends Behaviour
	
	#---------------------------------------------------------------------------
	func _process(_delta : float) -> void:
		pass


#---------------------------------------------------------------------------
#-------------------------------------------------------------------------------
class PursueBehaviour:
	extends Behaviour
	
	var _cell_size : Vector2 = Vector2.ZERO
	var _pathfinding : AStar2D = null
	var _path : PoolVector2Array
	var _last_target : Vector2 = Vector2.ZERO
	
	func _ready():
		var terrain_container = get_tree().get_nodes_in_group("terrain")
		if not terrain_container.empty():
			var terrain = terrain_container.front()
			_pathfinding = terrain.get_pathfinding()
			_cell_size = terrain.get_cell_size()
			
	
	#---------------------------------------------------------------------------
	func _process(delta : float) -> void:
		var target = _brain.subject.get_target()
		
		if target != _last_target:
			_last_target = target
			
			var subject_point = _pathfinding.get_closest_point(_brain.subject.position)
			var target_point = _pathfinding.get_closest_point(target)
			_path = _pathfinding.get_point_path(subject_point, target_point)
			
		if _path and _path.size() > 1:
			var next_pos = (Vector2(_path[1].x, _path[1].y))# * _cell_size
				#+_cell_size * 0.5)
				
			if next_pos.y < _brain.subject.position.y:
				_brain.subject.thrust_jetpack(delta)
			
			if next_pos.y - _brain.subject.position.y < _cell_size.y:
				_path.remove(0)


#-------------------------------------------------------------------------------
