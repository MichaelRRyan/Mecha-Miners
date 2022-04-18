extends Area2D

var _entities_in_range = []


#-------------------------------------------------------------------------------
func get_entities_in_range() -> Array:
	return _entities_in_range


#-------------------------------------------------------------------------------
func is_entity_within_range_of(pos : Vector2, check_range : float) -> bool:
	var range_squared = check_range * check_range
	
	for entity in _entities_in_range:
		if (entity.position - pos).length_squared() <= range_squared:
			return true

	return false


#-------------------------------------------------------------------------------
func _on_EntitySensor_body_entered(body):
	# Adds the body to the container if it's not a parent.
	if not body.is_a_parent_of(self):
		_entities_in_range.append(body)


#-------------------------------------------------------------------------------
func _on_EntitySensor_body_exited(body):
	_entities_in_range.erase(body)


#-------------------------------------------------------------------------------
