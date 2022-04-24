extends Control


# ------------------------------------------------------------------------------
func _on_MintButton_pressed():
	pass # Replace with function body.
	
	
# ------------------------------------------------------------------------------
func _on_SentButton_pressed():
	pass # Replace with function body.


# ------------------------------------------------------------------------------
func _on_BackButton_pressed():
	if get_tree().change_scene("res://scenes/ui/screens/ShipScreen.tscn") != OK:
		print("Error changing to ShipScreen.")


# ------------------------------------------------------------------------------
