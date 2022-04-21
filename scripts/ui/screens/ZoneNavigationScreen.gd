extends Control
	

# ------------------------------------------------------------------------------
func _on_DropZone1Button_pressed():
	if get_tree().change_scene("res://scenes/world/World.tscn") != OK:
		print("Error changing from ZoneNavigationScreen to the World scene.")
	

# ------------------------------------------------------------------------------
func _on_BackButton_pressed():
	if get_tree().change_scene("res://scenes/ui/screens/PlanetNavigationScreen.tscn") != OK:
		print("Error changing from ZoneNavigationScreen to PlanetNavigationScreen.")


# ------------------------------------------------------------------------------
