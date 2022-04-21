class_name CollectItemsBehaviour
extends Behaviour

const AVOID_ENTITY_RANGE = 64.0

var _terrain : Terrain = null
var _item_sensor = null
var _entity_sensor = null

var _target_item = null
var _pursue_created = false


#-------------------------------------------------------------------------------
func _init():
	_name = "CollectItemsBehaviour"
	_priority = 4


#-------------------------------------------------------------------------------
func on_rentered():
	if _target_item != null and is_instance_valid(_target_item):
		_brain.set_target(_target_item.global_position)


#-------------------------------------------------------------------------------
func _ready() -> void:
	var terrain_container = get_tree().get_nodes_in_group("terrain")
	if not terrain_container.empty():
		_terrain = terrain_container.front()
	
	_item_sensor = _brain.find_node("ItemSensor")
	if _item_sensor == null:
		_brain.pop_behaviour()
		return
	
	_entity_sensor = _brain.find_node("EntitySensor")
	if _entity_sensor == null:
		_brain.pop_behaviour()
		return


#-------------------------------------------------------------------------------
func _process(_delta : float) -> void:
	if _active and _target_item == null:
		var closest_dist = 0
		
		# Checks for spotted mineral items to collect.
		for item in _item_sensor.get_items_in_range():
			
			if item != null and is_instance_valid(item):
				
				# Checks there's not already another entity close to the item.
				var pos = item.global_position
				if not _entity_sensor.is_entity_within_range_of(pos, AVOID_ENTITY_RANGE):
					
					# If another mineral has not been found yet, or this one is closer.
					var dist = (pos - global_position).length_squared()
					if _target_item == null or dist < closest_dist:
						closest_dist = dist
						_target_item = item

		# If no items could be found, return from behaviour.
		if _target_item == null or not is_instance_valid(_target_item):
			_brain.pop_behaviour()
			
		else:
			if not _target_item.is_connected("picked_up", self, "_on_target_item_picked_up"):
				_target_item.connect("picked_up", self, "_on_target_item_picked_up")
			_pursue(_target_item.global_position)
			

#-------------------------------------------------------------------------------
func _pursue(pos : Vector2) -> void:
	_brain.set_target(pos)
	
	if not _pursue_created:
		_pursue_created = true
		
		# Creates a new pursue behaviour that does not disable once target is reached.
		var pursue = PursueBehaviour.new(false)
		
		# Connects to the target reached signal and adds pursue as a sub behaviour. 
		var _r = pursue.connect("target_reached", self, "_on_PursueBehaviour_target_reached")
		_add_sub_behaviour(pursue)


#-------------------------------------------------------------------------------
func _on_PursueBehaviour_target_reached() -> void:
	call_deferred("_target_found")


#-------------------------------------------------------------------------------
func _on_target_item_picked_up():
	call_deferred("_target_found")


#-------------------------------------------------------------------------------
func _target_found():
	_target_item = null


#-------------------------------------------------------------------------------
