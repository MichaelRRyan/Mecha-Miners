extends Area2D

signal item_found(item_object)

var _items_in_range = []


#-------------------------------------------------------------------------------
func get_items_in_range() -> Array:
	return _items_in_range


#-------------------------------------------------------------------------------
func _on_ItemSensor_body_entered(body : Node2D):
	if body.is_in_group("item"):
		_items_in_range.append(body)
		var _r = body.connect("picked_up", self, "_on_item_picked_up", [body])
		emit_signal("item_found", body)
		

#-------------------------------------------------------------------------------
func _on_ItemSensor_body_exited(body : Node2D):
	if body.is_in_group("item"):
		_items_in_range.erase(body)
		body.disconnect("picked_up", self, "_on_item_picked_up")
		


#-------------------------------------------------------------------------------
func _on_item_picked_up(item_obj : KinematicBody2D) -> void:
	if _items_in_range.has(item_obj):
		_items_in_range.erase(item_obj)


#-------------------------------------------------------------------------------
