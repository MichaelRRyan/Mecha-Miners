class_name Behaviour
extends Node2D

var _brain : AIBrain = null setget set_brain
var _active : bool = false setget set_active
var _name : String = "Behaviour"
var _priority : int = 0

#-------------------------------------------------------------------------------
func get_class() -> String:
	return _name


#-------------------------------------------------------------------------------
func set_brain(brain : AIBrain) -> void:
	_brain = brain


#-------------------------------------------------------------------------------
func set_active(value):
	_active = value


#-------------------------------------------------------------------------------
func get_priority() -> int:
	return _priority
#-------------------------------------------------------------------------------
