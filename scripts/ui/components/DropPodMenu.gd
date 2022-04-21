extends Control

signal gems_amount_changed(amount)

signal menu_closed

var drop_pod_inventory = Inventory.new()

onready var player_inventory_ui = $HDivider/InventoryList/PlayerInventoryUI
onready var drop_pod_inventory_ui = $HDivider/InventoryList/DropPodInventoryUI


# ------------------------------------------------------------------------------
func _ready():
	drop_pod_inventory_ui.set_inventory(drop_pod_inventory)
	drop_pod_inventory_ui.refresh()


# ------------------------------------------------------------------------------
func _on_DepositGems_pressed():
	var size = player_inventory_ui.inventory.size
	for i in range(0, size):
		var index = size - 1 - i
		var stack = player_inventory_ui.get_item_stack(index)
		if stack and stack.type == ItemData.ItemType.GEM:
			_move_stack(index, player_inventory_ui.inventory, drop_pod_inventory)
	
	player_inventory_ui.refresh()
	drop_pod_inventory_ui.refresh()
			

# ------------------------------------------------------------------------------
func _on_DepositAll_pressed():
	var size = player_inventory_ui.inventory.size
	for i in range(0, size):
		var index = size - 1 - i
		_move_stack(index, player_inventory_ui.inventory, drop_pod_inventory)
	
	player_inventory_ui.refresh()
	drop_pod_inventory_ui.refresh()


# ------------------------------------------------------------------------------
func _on_WithdrawAll_pressed():
	var size = drop_pod_inventory.size
	for i in range(0, size):
		var index = size - 1 - i
		_move_stack(index, drop_pod_inventory, player_inventory_ui.inventory)
	
	player_inventory_ui.refresh()
	drop_pod_inventory_ui.refresh()


# ------------------------------------------------------------------------------
func _on_ReturnToShip_pressed():
	# Moves the contents of the drop pod to the ship.
	var size = drop_pod_inventory.size
	for i in range(0, size):
		var index = size - 1 - i
		_move_stack(index, drop_pod_inventory, GameState.ship_inventory)
	
	# Moves the contents of the player inventory to the ship.
	size = player_inventory_ui.inventory.size
	for i in range(0, size):
		var index = size - 1 - i
		_move_stack(index, player_inventory_ui.inventory, GameState.ship_inventory)
	
	get_tree().paused = false
	if get_tree().change_scene("res://scenes/ui/screens/ShipScreen.tscn") != OK:
		print("Error changing from DropPodMenu to ShipScreen.")


# ------------------------------------------------------------------------------
func _on_CloseMenu_pressed():
	emit_signal("menu_closed")


# ------------------------------------------------------------------------------
func show():
	visible = true
	
	if player_inventory_ui.inventory == null:
		
		# Finds the local player (to interface with their inventory).
		var managers = get_tree().get_nodes_in_group("player_manager")
		if managers and managers.size():
			
			var local_player = managers[0].get_local_player()
			if local_player:
				player_inventory_ui.set_inventory(local_player.inventory)
	
	player_inventory_ui.refresh()


# ------------------------------------------------------------------------------
func hide():
	visible = false
	var gems = player_inventory_ui.inventory.get_gem_count()
	emit_signal("gems_amount_changed", gems)


# ------------------------------------------------------------------------------
func _on_PlayerInventoryUI_slot_pressed(slot_index):
	_move_stack(slot_index, player_inventory_ui.inventory, drop_pod_inventory)
	player_inventory_ui.refresh()
	drop_pod_inventory_ui.refresh()


# ------------------------------------------------------------------------------
func _on_DropPodInventoryUI_slot_pressed(slot_index):
	_move_stack(slot_index, drop_pod_inventory, player_inventory_ui.inventory)
	player_inventory_ui.refresh()
	drop_pod_inventory_ui.refresh()


# ------------------------------------------------------------------------------
func _move_stack(stack_index : int, from : Inventory, to : Inventory):
	
	# Tries to remove a stack at the specified index.
	var stack = from.remove_stack(stack_index)
	
	# Checks if a stack was removed and tries to add it to the new inventory.
	if stack:
		var remainder = to.add_stack(stack)
		
		# If the new inventory was full, adds the remainder back to the first 
		# 	inventory.
		if remainder:
			from.add_stack(remainder)
			
			
# ------------------------------------------------------------------------------
