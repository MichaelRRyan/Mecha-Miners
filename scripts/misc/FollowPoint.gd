extends Node2D

export var dampener = 0.1


# ------------------------------------------------------------------------------
func _on_Player_new_velocity(velocity):
	position = velocity * dampener


# ------------------------------------------------------------------------------
