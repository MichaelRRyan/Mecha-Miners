extends ColorRect

signal slot_pressed(slot_index)


var inventory : Inventory = null
var item_slots = []


# ------------------------------------------------------------------------------
func set_inventory(reference):
	inventory = reference


# -----------------------------------------------------------------------------
func refresh():
	var stack_count = inventory.get_stack_count()
	
	for i in range(item_slots.size()):
		
		if i < stack_count:
			item_slots[i].set_item_stack(inventory.item_stacks[i])
		else:
			item_slots[i].set_item_stack(null)


# -----------------------------------------------------------------------------
func add_stack(new_stack):
	var remainder = inventory.add_stack(new_stack)
	refresh()
	return remainder

# -----------------------------------------------------------------------------
func remove_stack(stack_index):
	var stack = inventory.remove_stack(stack_index)
	refresh()
	return stack
	
	
# -----------------------------------------------------------------------------
func get_item_stack(slot_index):
	return inventory.get_item_stack(slot_index)


# -----------------------------------------------------------------------------
func _ready():
	_get_slots()


# -----------------------------------------------------------------------------
func _get_slots():
	var columns = $Rows.get_children()
	for column in columns:
		
		var slots = column.get_children()
		for slot in slots:
			# Connects the button pressed signal.
			slot.connect("pressed", self, "_on_ItemSlot_pressed", 
				[item_slots.size()])
			
			# Adds the slot to the list.
			item_slots.append(slot)


# -----------------------------------------------------------------------------
func _on_ItemSlot_pressed(index):
	emit_signal("slot_pressed", index)


# -----------------------------------------------------------------------------
