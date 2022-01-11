extends Control

signal menu_closed


# -----------------------------------------------------------------------------
func _on_ReturnToShip_pressed():
	get_tree().paused = false
	if get_tree().change_scene("res://scenes/screens/ShipScreen.tscn") != OK:
		print("Error changing from DropPodMenu to ShipScreen.")


# -----------------------------------------------------------------------------
func _on_CloseMenu_pressed():
	emit_signal("menu_closed")


# -----------------------------------------------------------------------------
