class_name Inventory

const SIZE = 18

# Contains ItemStacks = { type : ItemData.ItemType, quantity : int }
var item_stacks = []


# ------------------------------------------------------------------------------
func get_stack_count():
	return item_stacks.size()

	
# ------------------------------------------------------------------------------
func get_item_stack(stack_index):
	if stack_index < item_stacks.size():
		return item_stacks[stack_index]
	else:
		return null


# ------------------------------------------------------------------------------
func get_gem_count():
	var count = 0
	
	for stack in item_stacks:
		if stack.type == ItemData.ItemType.GEM:
			count += stack.quantity
			
	return count


# ------------------------------------------------------------------------------
func count_and_remove_gems():
	var count = 0
	var deletion_queue = []
	
	for stack in item_stacks:
		if stack.type == ItemData.ItemType.GEM:
			count += stack.quantity
			deletion_queue.append(stack)
	
	for item in deletion_queue:
		item_stacks.erase(item)
	
	return count


# ------------------------------------------------------------------------------
func remove_stack(stack_index):
	if stack_index < item_stacks.size():
		var stack = item_stacks[stack_index]
		item_stacks.remove(stack_index)
		return stack
		
	return null

# ------------------------------------------------------------------------------
func add_stack(new_stack):
	
	# Loops through all the stacks in the inventory and adds to them if the item
	# 	types match. Returns what's left of the stack, or null.
	var remaining_stack = _add_to_existing_stack(new_stack)
	
	# If there's still a stack, adds it to the end of the inventory if there's 
	# 	space.
	if remaining_stack and item_stacks.size() < SIZE:
		item_stacks.append(remaining_stack)
		return null
	
	# if there's still a stack, return the remainder of the stack.
	return remaining_stack


# ------------------------------------------------------------------------------
func _add_to_existing_stack(new_stack):
	new_stack = new_stack.duplicate()
	var item_data = ItemData.get_data(new_stack.type)
	
	# Loops through each item stack in the inventory.
	for stack in item_stacks:
		
		# If the stack types match and the quantity is below the max.
		if stack.type == new_stack.type and stack.quantity < item_data.max_quantity:
			
			# Find the remainder once the stacks are joined.
			var joined_quantity = stack.quantity + new_stack.quantity
			var remainder = max(0, joined_quantity - item_data.max_quantity)
			
			if remainder > 0:
				stack.quantity = item_data.max_quantity
				new_stack.quantity = remainder
			
			else:
				stack.quantity += new_stack.quantity
				return null # The stack is now, empty, returns null.
	
	# Returns what's left of the stack.
	return new_stack


# ------------------------------------------------------------------------------
