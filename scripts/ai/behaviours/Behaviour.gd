class_name Behaviour
extends Node2D

var _brain : AIBrain = null setget set_brain
var _active : bool = false setget set_active
var _name : String = "Behaviour"
var _priority : int = 0
var _sub_behaviours : Array = []

#-------------------------------------------------------------------------------
func get_class() -> String:
	return _name


#-------------------------------------------------------------------------------
func set_brain(brain : AIBrain) -> void:
	_brain = brain


#-------------------------------------------------------------------------------
func set_active(value):
	_active = value
	
	for behaviour in _sub_behaviours:
		behaviour.set_active(value)


#-------------------------------------------------------------------------------
func get_priority() -> int:
	return _priority


#-------------------------------------------------------------------------------
func _add_sub_behaviour(behaviour : Behaviour):
	behaviour.set_brain(_brain)
	_sub_behaviours.append(behaviour)
	add_child(behaviour)
	behaviour.set_active(true)
	
	if _brain._debug:
		print("AI " + _brain.subject.name + " adding sub behaviour " + behaviour.get_class())


#-------------------------------------------------------------------------------
func _remove_sub_behaviour(behaviour : Behaviour):
	if _sub_behaviours.has(behaviour):
		_sub_behaviours.erase(behaviour)
		remove_child(behaviour)
		behaviour.queue_free()
		
		if _brain._debug:
			print("AI " + _brain.subject.name + " removing sub behaviour " + behaviour.get_class())
	else:
		print_debug("The behaviour passed is not a sub behaviour.")

#-------------------------------------------------------------------------------
# Cleans up all sub behaviours when this behaviour is removed.
func _exit_tree():
	for behaviour in _sub_behaviours:
		remove_child(behaviour)
		behaviour.queue_free()
	_sub_behaviours.clear()


#-------------------------------------------------------------------------------
