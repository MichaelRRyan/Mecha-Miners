extends KinematicBody2D

signal picked_up()

var velocity = Vector2.ZERO


#-------------------------------------------------------------------------------
func _on_picked_up():
	emit_signal("picked_up")


#-------------------------------------------------------------------------------
func accelerate(force):
	velocity += force


#-------------------------------------------------------------------------------
