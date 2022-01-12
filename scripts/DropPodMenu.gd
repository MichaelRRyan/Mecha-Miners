extends Control

signal menu_closed

var local_player = null
var inventory_slots = null
var drop_pod_slots = null


# -----------------------------------------------------------------------------
func _ready():
	inventory_slots = _get_slots($HDivider/InventoryList/InventoryBackground/Rows)
	drop_pod_slots = _get_slots($HDivider/InventoryList/DropPodBackground/Rows)


# -----------------------------------------------------------------------------
func _get_slots(rows):
	var return_slots = []
	
	var columns = rows.get_children()
	for column in columns:
		
		var slots = column.get_children()
		for slot in slots:
			return_slots.append(slot)
	
	return return_slots


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
			_load_inventory(local_player.inventory)


# -----------------------------------------------------------------------------
func _load_inventory(inventory : Inventory):
	var stack_count = inventory.get_stack_count()
	
	for i in range(inventory_slots.size()):
		
		if i < stack_count:
			inventory_slots[i].set_item_stack(inventory.item_stacks[i])
		else:
			inventory_slots[i].set_item_stack(null)
	

# -----------------------------------------------------------------------------
