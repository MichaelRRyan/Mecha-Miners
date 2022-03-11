extends Node2D

var subject : Node2D = null
var _behaviour_stack : Array = []


#-------------------------------------------------------------------------------
func set_target(new_target : Vector2) -> void:
	subject.set_target(new_target)


#-------------------------------------------------------------------------------
func get_target() -> Vector2:
	return subject.get_target()


#-------------------------------------------------------------------------------
# Adds a behaviour to the top of the stack (becomes the current behaviour).
func add_behaviour(new_behaviour : Behaviour) -> void:
	if not _behaviour_stack.empty():
		_disable(_behaviour_stack.back())
		
	_behaviour_stack.push_back(new_behaviour)
	_set_as_current(new_behaviour)


#-------------------------------------------------------------------------------
# Pops a behaviour from the stack, with the new top becoming the current.
func pop_behaviour() -> void:
	if not _behaviour_stack.empty():
		
		var behaviour = _behaviour_stack.pop_back()
		#print("AI " + subject.name + " exiting " + behaviour.get_class())
		_disable(behaviour)
		behaviour.queue_free()
		
		# If still not empty.
		if not _behaviour_stack.empty():
			_set_as_current(_behaviour_stack.back())
		else:
			add_behaviour(IdleBehaviour.new())


#-------------------------------------------------------------------------------
# Switches the current running behaviour with another, removing the original.
func change_behaviour(new_behaviour : Behaviour) -> void:
	pop_behaviour()
	add_behaviour(new_behaviour)


#-------------------------------------------------------------------------------
func _set_as_current(behaviour : Behaviour) -> void:
	#print("AI " + subject.name + " entering " + behaviour.get_class())
	behaviour.set_brain(self)
	add_child(behaviour)


#-------------------------------------------------------------------------------
func _disable(behaviour : Behaviour) -> void:
	remove_child(behaviour)


#-------------------------------------------------------------------------------
func _ready() -> void:
	subject = get_parent()
	add_behaviour(IdleBehaviour.new())


#-------------------------------------------------------------------------------
func _process(_delta : float) -> void:
	pass


#-------------------------------------------------------------------------------
