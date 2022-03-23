extends AIBrain

var _behaviour_stack : Array = []
var _debug : bool = false
var _main_camera = null
var _previous_camera_focus = null


#-------------------------------------------------------------------------------
func is_debug() -> bool:
	return _debug


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
		_behaviour_stack.back().set_active(false)
		
	_behaviour_stack.push_back(new_behaviour)
	_set_as_current(new_behaviour)
	add_child(new_behaviour)


#-------------------------------------------------------------------------------
# Pops a behaviour from the stack, with the new top becoming the current.
func pop_behaviour() -> void:
	if not _behaviour_stack.empty():
		
		var behaviour = _behaviour_stack.pop_back()
		print("AI " + subject.name + " exiting " + behaviour.get_class())
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
	print("AI " + subject.name + " entering " + behaviour.get_class())
	behaviour.set_brain(self)
	behaviour.set_active(true)


#-------------------------------------------------------------------------------
func _disable(behaviour : Behaviour) -> void:
	remove_child(behaviour)


#-------------------------------------------------------------------------------
func _ready() -> void:
	subject = get_parent()
	add_behaviour(IdleBehaviour.new())
	
	var main_cameras = get_tree().get_nodes_in_group("main_camera")
	if main_cameras != null and not main_cameras.empty():
		_main_camera = main_cameras.front()


#-------------------------------------------------------------------------------
func _input(event):
	# Toggles AI debug mode.
	if event.is_action_pressed("ai_debug"):
		_debug = not _debug
	
	if event.is_action_pressed("ai_perspective"):
		
		# If the main camera exists.
		if _main_camera != null:
			
			# If the camera is following a node.
			var camera_focus : Node = _main_camera.get_parent()
			if camera_focus != null:
				
				camera_focus.remove_child(_main_camera)
				
				if _previous_camera_focus == null:
					_previous_camera_focus = camera_focus
					add_child(_main_camera)
					
				else:
					_previous_camera_focus.add_child(_main_camera)
					_previous_camera_focus = null
					
				_main_camera.position = Vector2.ZERO


#-------------------------------------------------------------------------------
