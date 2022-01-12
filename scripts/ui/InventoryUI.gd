extends ColorRect

signal slot_pressed(slot_index)


var item_slots = []


# -----------------------------------------------------------------------------
func load_inventory(inventory : Inventory):
	var stack_count = inventory.get_stack_count()
	
	for i in range(item_slots.size()):
		
		if i < stack_count:
			item_slots[i].set_item_stack(inventory.item_stacks[i])
		else:
			item_slots[i].set_item_stack(null)


# -----------------------------------------------------------------------------
func get_item_stack(slot_index):
	return item_slots[slot_index].get_item_stack()


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
			item_slots.connect("pressed", self, "_on_ItemSlot_pressed", 
				[item_slots.size()])
			
			# Adds the slot to the list.
			item_slots.append(slot)


# -----------------------------------------------------------------------------
func _on_ItemSlot_pressed(index):
	emit_signal("slot_pressed", index)


# -----------------------------------------------------------------------------
