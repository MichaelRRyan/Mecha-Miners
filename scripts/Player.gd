extends "res://scripts/entities/Entity.gd"


# -----------------------------------------------------------------------------
func _process(_delta):
	# Don't process if in the editor.
	if Engine.editor_hint:
		return
	
	# Don't process if online and not the network master, is updated instead.
	if Network.is_online and not is_network_master():
		return
	
	if is_human:
		_target = get_global_mouse_position()



# -----------------------------------------------------------------------------
func _handle_vertical_movement(delta):
	
	._handle_vertical_movement(delta)

	if is_human:
		# If the jump input was just pressed.
		if Input.is_action_just_pressed("jump"):
			jump(delta)
			
		# If already flying and the jump button is down, keep flying.
		elif Input.is_action_pressed("jump") and $Jetpack.is_flying():
			thrust_jetpack(delta)


# -----------------------------------------------------------------------------
func _handle_horizontal_movement(delta):
	
	# Get the horizontal input if human controlled.
	if is_human:
		direction = (Input.get_action_strength("move_right") - 
					 Input.get_action_strength("move_left"))
	
	._handle_horizontal_movement(delta)

	
# -----------------------------------------------------------------------------
