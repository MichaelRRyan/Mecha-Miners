extends Sprite

export var standard_color : Color = Color(1, 1, 1)
export var hover_color : Color = Color(1, 0, 0)


# -----------------------------------------------------------------------------
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)


# -----------------------------------------------------------------------------
func _process(_delta):
	position = get_global_mouse_position()


# -----------------------------------------------------------------------------
func _on_Detector_body_entered(_body):
	modulate = hover_color


# -----------------------------------------------------------------------------
func _on_Detector_body_exited(_body):
	modulate = standard_color


# -----------------------------------------------------------------------------
## TEMPORARY.
#func _input(event):
#	if event is InputEventKey:
#		if event.is_action_pressed("toggle_network_panel"):
#
#			if visible: Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
#			else: Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
#
#			visible = !visible


# -----------------------------------------------------------------------------
func _on_GUIManager_menu_toggled(opened):
	if opened: Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else: Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	
	visible = !opened


# -----------------------------------------------------------------------------
