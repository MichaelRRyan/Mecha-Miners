extends Control


# ------------------------------------------------------------------------------
func _on_StartButton_pressed():
	if get_tree().change_scene("res://scenes/ui/screens/LoginScreen.tscn") != OK:
		print_debug("Cannot change scene to LoginScreen.")
	
	
# ------------------------------------------------------------------------------
func _on_OptionsButton_pressed():
	if get_tree().change_scene("res://scenes/ui/screens/OptionsScreen.tscn") != OK:
		print_debug("Cannot change scene to OptionsScreen.")


# ------------------------------------------------------------------------------
func _on_ExitButton_pressed():
	if get_tree().change_scene("res://scenes/ui/screens/ExitScreen.tscn") != OK:
		print_debug("Cannot change scene to ExitScreen.")


# ------------------------------------------------------------------------------
func _on_OfflineButton_pressed():
	if get_tree().change_scene("res://scenes/ui/screens/ShipScreen.tscn") != OK:
		print_debug("Cannot change scene to ShipScreen.")


# ------------------------------------------------------------------------------
