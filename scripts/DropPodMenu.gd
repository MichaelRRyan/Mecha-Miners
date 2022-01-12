extends Control

signal menu_closed

var local_player = null


# -----------------------------------------------------------------------------
func _ready():
	# Finds the local player (to interface with their inventory).
	var managers = get_tree().get_nodes_in_group("player_manager")
	if managers and managers.size():
		local_player = managers[0].get_local_player()


# -----------------------------------------------------------------------------
func _on_ReturnToShip_pressed():
	get_tree().paused = false
	if get_tree().change_scene("res://scenes/screens/ShipScreen.tscn") != OK:
		print("Error changing from DropPodMenu to ShipScreen.")


# -----------------------------------------------------------------------------
func _on_CloseMenu_pressed():
	emit_signal("menu_closed")


# -----------------------------------------------------------------------------
