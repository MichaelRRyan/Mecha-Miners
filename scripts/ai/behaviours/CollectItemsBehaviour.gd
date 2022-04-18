class_name CollectItemsBehaviour
extends Behaviour

const AVOID_ENTITY_RANGE = 64.0

var _terrain : Terrain = null
var _item_sensor = null
var _entity_sensor = null
var _target_found = false
var _pursue_created = false # Set to true once a sub pursue behaviour is created.


#-------------------------------------------------------------------------------
func _init():
	_name = "CollectItemsBehaviour"
	_priority = 10


#-------------------------------------------------------------------------------
func _ready() -> void:
	var terrain_container = get_tree().get_nodes_in_group("terrain")
	if not terrain_container.empty():
		_terrain = terrain_container.front()
	
	_item_sensor = _brain.find_node("ItemSensor")
	if _item_sensor == null:
		set_process(false)
		_brain.pop_behaviour()
	
	_entity_sensor = _brain.find_node("EntitySensor")
	if _entity_sensor == null:
		set_process(false)
		_brain.pop_behaviour()


#-------------------------------------------------------------------------------
func _process(_delta : float) -> void:
	if _active and not _target_found:
		var item_found = null
		var closest_dist = 0
		
		# Checks for spotted mineral items to collect.
		for item in _item_sensor.get_items_in_range():
			
			# Checks there's not already another entity close to the item.
			var pos = item.global_position
			if not _entity_sensor.is_entity_within_range_of(pos, AVOID_ENTITY_RANGE):
				
				# If another mineral has not been found yet, or this one is closer.
				var dist = (pos - global_position).length_squared()
				if not item_found or dist < closest_dist:
					closest_dist = dist
					item_found = item

		# If no items could be found, return from behaviour.
		if item_found == null:
			_brain.pop_behaviour()
			
		else:
			if _brain.is_debug():
				print("AI " + _brain.subject.name + " item found in " + get_class() + ".")
			
			_target_found = true
			if not item_found.is_connected("picked_up", self, "_on_target_item_picked_up"):
				item_found.connect("picked_up", self, "_on_target_item_picked_up")
			_pursue(item_found.global_position)
			

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
	call_deferred("set", "_target_found", false)
	
	if _brain.is_debug():
		print("AI " + _brain.subject.name + " item reached while in " + get_class() + ".")


#-------------------------------------------------------------------------------
func _on_target_item_picked_up():
	call_deferred("set", "_target_found", false)


#-------------------------------------------------------------------------------
