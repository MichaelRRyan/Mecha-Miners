extends AIBehaviours # So we can access all behaviours without prefix.

var state : Behaviour = null


# -----------------------------------------------------------------------------
func change_state(new_state : Behaviour) -> void:
	if state:
		state.queue_free()
	
	state = new_state
	add_child(state)
	state.owner = self
	state.set_brain(self)
	

# -----------------------------------------------------------------------------
func _ready() -> void:
	change_state(IdleBehaviour.new())


# -----------------------------------------------------------------------------
func _process(_delta : float) -> void:
	pass


# -----------------------------------------------------------------------------
