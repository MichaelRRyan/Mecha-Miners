extends Node

export var cursor_character : String = '>'
export var list_character : String  = '-'


func _ready():
	setup_buttons()


func setup_buttons():
	var buttons = get_tree().get_nodes_in_group("button")
	
	if buttons and not buttons.empty():
		for button in buttons:
			var _r = button.connect("focus_entered", self, "_on_button_focus_entered", [button])
			_r = button.connect("focus_exited", self, "_on_button_focus_exited", [button])
			_r = button.connect("mouse_entered", self, "_on_button_mouse_entered", [button])
			
		buttons[0].grab_focus()


func _on_button_focus_entered(button : Button):
	if not button.text.empty() and button.text[0] == list_character:
		button.text = button.text.replace(list_character, cursor_character)
		

func _on_button_focus_exited(button : Button):
	if not button.text.empty() and button.text[0] == cursor_character:
		button.text = button.text.replace(cursor_character, list_character)


func _on_button_mouse_entered(button : Button):
	button.grab_focus()
