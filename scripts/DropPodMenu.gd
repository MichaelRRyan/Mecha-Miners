extends Control

signal menu_closed

var local_player = null
var drop_pod_inventory = Inventory.new()

onready var player_inventory_ui = $HDivider/InventoryList/PlayerInventoryUI
onready var drop_pod_inventory_ui = $HDivider/InventoryList/DropPodInventoryUI


# -----------------------------------------------------------------------------
func _on_ReturnToShip_pressed():
	get_tree().paused = false
	if get_tree().change_scene("res://scenes/screens/ShipScreen.tscn") != OK:
		print("Error changing from DropPodMenu to ShipScreen.")


# -----------------------------------------------------------------------------
func _on_CloseMenu_pressed():
	emit_signal("menu_closed")


# -----------------------------------------------------------------------------
func show():
	visible = true
	
	# Finds the local player (to interface with their inventory).
	var managers = get_tree().get_nodes_in_group("player_manager")
	if managers and managers.size():
		local_player = managers[0].get_local_player()
		if local_player:
			player_inventory_ui.load_inventory(local_player.inventory)


# -----------------------------------------------------------------------------
func _on_PlayerInventoryUI_slot_pressed(slot_index):
	pass # Replace with function body.


# -----------------------------------------------------------------------------
func _on_DropPodInventoryUI_slot_pressed(slot_index):
	pass # Replace with function body.


# -----------------------------------------------------------------------------
