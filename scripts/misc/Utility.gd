extends Node

var _debug_mode = true


#-------------------------------------------------------------------------------
func get_dependency(group_name : String) -> Node:
	var container = get_tree().get_nodes_in_group(group_name)
	if not container.empty():
		return container.front()
	return null


#-------------------------------------------------------------------------------
func is_debug_mode() -> bool:
	return _debug_mode


#-------------------------------------------------------------------------------
