class_name Behaviour
extends Node2D

var _brain : AIBrain = null setget set_brain


#-------------------------------------------------------------------------------
func get_class() -> String:
	return "Behaviour"


#-------------------------------------------------------------------------------
func set_brain(brain : AIBrain) -> void:
	_brain = brain


#-------------------------------------------------------------------------------
