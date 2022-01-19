extends Control
	
	
func _on_FreeForAllButton_pressed():
	if get_tree().change_scene("res://scenes/screens/ZoneNavigationScreen.tscn") != OK:
		print("Error changing from PlanetNavigationScreen to ZoneNavigationScreen.")


func _on_BackButton_pressed():
	if get_tree().change_scene("res://scenes/screens/ShipScreen.tscn") != OK:
		print("Error changing from PlanetNavigationScreen to ShipScreen.")
