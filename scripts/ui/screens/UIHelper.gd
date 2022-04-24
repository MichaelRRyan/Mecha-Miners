extends Node

export var cursor_character : String = '>'
export var list_character : String  = '-'


# ------------------------------------------------------------------------------
func _ready():
	setup_buttons()


# ------------------------------------------------------------------------------
func setup_buttons():
	var buttons = get_tree().get_nodes_in_group("button")
	
	if buttons and not buttons.empty():
		for button in buttons:
			var _r = button.connect("mouse_entered", self, "_on_button_mouse_entered", [button])
			
		buttons[0].grab_focus()


# ------------------------------------------------------------------------------
func _on_button_mouse_entered(button : Button):
	button.grab_focus()

	
# ------------------------------------------------------------------------------
