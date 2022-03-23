extends Node


#-------------------------------------------------------------------------------
func get_dependency(group_name : String) -> Node:
	var container = get_tree().get_nodes_in_group(group_name)
	if not container.empty():
		return container.front()
	return null


#-------------------------------------------------------------------------------
