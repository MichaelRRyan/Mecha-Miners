extends Node2D

export var dampener = 0.1

var _target : Node2D = null

# ------------------------------------------------------------------------------
func set_target(new_target : Node2D):
	if _target != null:
		_target.disconnect("new_velocity", self, "_on_Target_new_velocity")
	
	_target = new_target
	_target.connect("new_velocity", self, "_on_Target_new_velocity")
	position = _target.position
	
	
# ------------------------------------------------------------------------------
func _on_Target_new_velocity(velocity):
	position = _target.position + velocity * dampener


# ------------------------------------------------------------------------------
