extends AIBehaviours # So we can access all behaviours without prefix.

var subject : Node2D = null
var _behaviour_stack : Array = []


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
		_disable(behaviour)
		behaviour.queue_free()
		
		# If still not empty.
		if not _behaviour_stack.empty():
			_set_as_current(_behaviour_stack.back())


#-------------------------------------------------------------------------------
# Switches the current running behaviour with another, removing the original.
func change_behaviour(new_behaviour : Behaviour) -> void:
	pop_behaviour()
	add_behaviour(new_behaviour)


#-------------------------------------------------------------------------------
func _set_as_current(behaviour : Behaviour) -> void:
	add_child(behaviour)
	behaviour.owner = self
	behaviour.set_brain(self)


#-------------------------------------------------------------------------------
func _disable(behaviour : Behaviour) -> void:
	remove_child(behaviour)


#-------------------------------------------------------------------------------
func _ready() -> void:
	subject = get_parent()
	add_behaviour(PursueBehaviour.new())


#-------------------------------------------------------------------------------
func _process(_delta : float) -> void:
	pass


#-------------------------------------------------------------------------------
