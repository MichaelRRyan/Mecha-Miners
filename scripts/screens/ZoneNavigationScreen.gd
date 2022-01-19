extends Control
	

func _on_DropZone1Button_pressed():
	if get_tree().change_scene("res://scenes/Gameplay.tscn") != OK:
		print("Error changing from ZoneNavigationScreen to PlanetNavigationScreen.")
	

func _on_BackButton_pressed():
	if get_tree().change_scene("res://scenes/screens/PlanetNavigationScreen.tscn") != OK:
		print("Error changing from ZoneNavigationScreen to PlanetNavigationScreen.")



