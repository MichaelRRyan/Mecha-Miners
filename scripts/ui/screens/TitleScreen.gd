extends Control


# ------------------------------------------------------------------------------
func _on_StartButton_pressed():
	pass # Replace with function body.
	
	
# ------------------------------------------------------------------------------
func _on_OptionsButton_pressed():
	pass # Replace with function body.


# ------------------------------------------------------------------------------
func _on_ExitButton_pressed():
	if get_tree().change_scene("res://scenes/ui/screens/ExitScreen.tscn") != OK:
		print_debug("Cannot change scene to ExitScreen.")


# ------------------------------------------------------------------------------