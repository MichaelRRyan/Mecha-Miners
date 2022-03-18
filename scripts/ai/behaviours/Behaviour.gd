class_name Behaviour
extends Node2D

var _brain : AIBrain = null setget set_brain
var _active : bool = false setget set_active
var _name : String = "Behaviour"


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
