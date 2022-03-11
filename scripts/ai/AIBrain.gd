class_name AIBrain # Abstract AI Interface.
extends Node2D

var subject : Node2D = null


#-------------------------------------------------------------------------------
func set_target(_new_target : Vector2) -> void:
	assert(false)


#-------------------------------------------------------------------------------
func get_target() -> Vector2:
	assert(false)
	return Vector2.ZERO


#-------------------------------------------------------------------------------
# Adds a behaviour to the top of the stack (becomes the current behaviour).
func add_behaviour(_new_behaviour) -> void:
	assert(false)


#-------------------------------------------------------------------------------
# Pops a behaviour from the stack, with the new top becoming the current.
func pop_behaviour() -> void:
	assert(false)


#-------------------------------------------------------------------------------
# Switches the current running behaviour with another, removing the original.
func change_behaviour(_new_behaviour) -> void:
	assert(false)


#-------------------------------------------------------------------------------
