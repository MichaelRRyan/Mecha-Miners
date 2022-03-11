class_name Behaviour
extends Node

var _brain : AIBrain = null setget set_brain


#-------------------------------------------------------------------------------
func set_brain(brain) -> void:
	_brain = brain


#-------------------------------------------------------------------------------
func get_class() -> String:
	return "Behaviour"


#-------------------------------------------------------------------------------
