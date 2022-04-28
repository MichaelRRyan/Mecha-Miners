extends AIBrain

# The maximum downward velocity before the bot will try to slow itself.
export(float) var max_velocity_y = 100.0

var _debug : bool = false

var _behaviour_stack : Array = []
var _previous_camera_focus = null
var _highest_priority_behaviour = null
var _bravado = 0.5
var _ideal_crystal_count = 40


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
		
		var behaviour = _behaviour_stack.back()
		
		# Assigns the new highest priority behaviour.
		if _highest_priority_behaviour == behaviour:
			if _behaviour_stack.size() > 1:
				var index = _behaviour_stack.find(behaviour)
				
				_highest_priority_behaviour = _behaviour_stack.front()
				for i in range(1, index):
					if (_behaviour_stack[i].get_priority() > 
						_highest_priority_behaviour.get_priority()):
							_highest_priority_behaviour = _behaviour_stack[i]
					
			else:
				_highest_priority_behaviour = null
		
		_behaviour_stack.pop_back()
		
		if _debug:
			print("AI " + subject.name + " exiting " + behaviour.get_class())
			
		_disable(behaviour)
		behaviour.queue_free()
		
		# If still not empty.
		if not _behaviour_stack.empty():
			_set_as_current(_behaviour_stack.back(), true)
		else:
			add_behaviour(IdleBehaviour.new())


#-------------------------------------------------------------------------------
# Switches the current running behaviour with another, removing the original.
func change_behaviour(new_behaviour : Behaviour) -> void:
	pop_behaviour()
	add_behaviour(new_behaviour)
	
	
#-------------------------------------------------------------------------------	
# Switches the current running behaviour with another if the new behaviour has a
#	higher priority than the current highest, removing the original.
func request_add_behaviour(new_behaviour : Behaviour) -> void:
	if	(_highest_priority_behaviour == null or new_behaviour.get_priority() > 
		_highest_priority_behaviour.get_priority()):
			add_behaviour(new_behaviour)
			
	else: # Disposes of the behaviour.
		new_behaviour.queue_free()


#-------------------------------------------------------------------------------
func get_highest_priority():
	return _highest_priority_behaviour


#-------------------------------------------------------------------------------
func bravado(certainty : float) -> bool:
	return randf() < (_bravado * 2.0) * certainty


#-------------------------------------------------------------------------------
func get_ideal_value() -> int:
	return _ideal_crystal_count


#-------------------------------------------------------------------------------
func get_real_value() -> int:
	return subject.inventory.get_gem_count()


#-------------------------------------------------------------------------------
func _set_as_current(behaviour : Behaviour, var rentering = false) -> void:
	if _debug:
		if rentering:
			print("AI " + subject.name + " reentering " + behaviour.get_class())
		else:
			print("AI " + subject.name + " entering " + behaviour.get_class())
		
		$Status.text = subject.name + "\n" + behaviour.get_class()
		
	behaviour.set_brain(self)
	behaviour.set_active(true)
	
	if rentering:
		behaviour.on_rentered()
	
	if (_highest_priority_behaviour == null 
		or behaviour.get_priority() > _highest_priority_behaviour.get_priority()):
			_highest_priority_behaviour = behaviour


#-------------------------------------------------------------------------------
func _disable(behaviour : Behaviour) -> void:
	remove_child(behaviour)


#-------------------------------------------------------------------------------
func _ready() -> void:
	if Network.is_client():
		queue_free()
	
	subject = get_parent()
	var _r = subject.connect("died", self, "_on_subject_died")
	call_deferred("add_behaviour", IdleBehaviour.new())
	
	# Uses noise to get a random number that tends towards a middle point of 0.5.
	var noise = OpenSimplexNoise.new()
	noise.seed = randi()
	noise.period = 0.0000001
	noise.persistence = 5
	_bravado = 1 - (noise.get_noise_1d(0) + 1) * 0.5


#-------------------------------------------------------------------------------
func _input(event):
	if Utility.is_debug_mode():
		# Toggles AI debug mode.
		if event.is_action_pressed("ai_debug"):
			_debug = not _debug
			$Status.visible = _debug
			
			if not _behaviour_stack.empty():
				$Status.text = subject.name + "\n" + _behaviour_stack.back().get_class()
			else:
				$Status.text = subject.name + "\nNone"

	
#-------------------------------------------------------------------------------
func _on_subject_died():
	# Pops all behaviours.
	while not _behaviour_stack.empty():
		var behaviour = _behaviour_stack.pop_back()
		remove_child(behaviour)
		behaviour.queue_free()
	
	_highest_priority_behaviour = null
	add_behaviour(IdleBehaviour.new())


#-------------------------------------------------------------------------------
func _process(delta):
	# Slows itself if falling too fast.
	if subject.get_velocity().y > max_velocity_y:
		subject.thrust_jetpack(delta)
		
		
#-------------------------------------------------------------------------------
func _on_Entity_drop_pod_landed():
	if subject == null:
		subject = get_parent()
		
	subject.drop_pod.exit()

		
#-------------------------------------------------------------------------------
