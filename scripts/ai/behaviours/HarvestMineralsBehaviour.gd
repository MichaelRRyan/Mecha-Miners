class_name HarvestMineralsBehaviour
extends Behaviour

const AVOID_ENTITY_HARVEST_RANGE = 64.0
const AVOID_ENTITY_PICKUP_RANGE = 64.0

var _terrain : Terrain = null
var _entity_sensor = null
var _spotted_mineral_cells = []
var _spotted_mineral_items = []
var _target_found = false


#-------------------------------------------------------------------------------
func _init():
	_name = "HarvestMineralsBehaviour"
	_priority = 10

	
#-------------------------------------------------------------------------------
func add_spotted_mineral_cell(mineral_cell : Vector2) -> void:
	_spotted_mineral_cells.append(mineral_cell)


#-------------------------------------------------------------------------------
func add_spotted_mineral_item(mineral_item : Node2D) -> void:
	_spotted_mineral_items.append(mineral_item)


#-------------------------------------------------------------------------------
func _ready() -> void:
	var terrain_container = get_tree().get_nodes_in_group("terrain")
	if not terrain_container.empty():
		_terrain = terrain_container.front()
	
	var mineral_sensor : Node2D = _brain.find_node("MineralSensor")
	if mineral_sensor:
		var _v = mineral_sensor.connect("mineral_found", self, "_on_MineralSensor_mineral_found")
	
	var item_sensor : Node2D = _brain.find_node("ItemSensor")
	if item_sensor:
		var _v = item_sensor.connect("mineral_found", self, "_on_ItemSensor_mineral_found")
	
	_entity_sensor = _brain.find_node("EntitySensor")
	if _entity_sensor == null:
		set_process(false)
		_brain.pop_behaviour()


#-------------------------------------------------------------------------------
func _on_MineralSensor_mineral_found(mineral_position : Vector2) -> void:
	_spotted_mineral_cells.append(mineral_position)
	
	
#-------------------------------------------------------------------------------
func _on_ItemSensor_mineral_found(mineral_object : Node2D) -> void:
	_spotted_mineral_items.append(mineral_object)


#-------------------------------------------------------------------------------
func _process(_delta : float) -> void:
	if _active and not _target_found:
		var mineral_found = false
		var mineral_pos = Vector2.ZERO
		var closest_dist = 0
		
		var deletion_queue = []
		
		# Checks for spotted mineral items to collect.
		for mineral_item in _spotted_mineral_items:
			# Checks the item still exists.
			if mineral_item != null and is_instance_valid(mineral_item):
				
				var pos = mineral_item.global_position
				if not _is_entity_within_range(pos, AVOID_ENTITY_PICKUP_RANGE):
					
					# If another mineral has not been found yet, or this one is closer.
					var dist = (pos - global_position).length_squared()
					if not mineral_found or dist < closest_dist:
						mineral_pos = pos
						closest_dist = dist
						mineral_found = true
			else:
				deletion_queue.append(mineral_item)
		
		for item in deletion_queue:
			_spotted_mineral_items.erase(item)
		deletion_queue.clear()
		
		# If no items found, checks for spotted mineral tiles.
		if not mineral_found:
			for mineral_cell in _spotted_mineral_cells:
				# Checks the cell is still a mineral and has not been destroyed.
				if _terrain.is_mineral(mineral_cell):
					
					var pos = _terrain.map_to_world_centred(mineral_cell)
					if not _is_entity_within_range(pos, AVOID_ENTITY_HARVEST_RANGE):
						
						var dist = (pos - global_position).length_squared()
						if not mineral_found or dist < closest_dist:
							mineral_pos = pos
							closest_dist = dist
							mineral_found = true
				else:
					deletion_queue.append(mineral_cell)
				
		for item in deletion_queue:
			_spotted_mineral_cells.erase(item)
		deletion_queue.clear()
			
		# If no mineral tiles or items could be found, return from behaviour.
		if not mineral_found:
			_brain.pop_behaviour()
		else:
			_target_found = true
			
			if _brain.is_debug():
				print("AI " + _brain.subject.name + " found target while harvesting minerals.")
			
			_pursue(mineral_pos)
			

#-------------------------------------------------------------------------------
func _on_PursueBehaviour_target_reached() -> void:
	
	if _brain.is_debug():
		print("AI " + _brain.subject.name + " target reached while harvesting minerals.")
	
	# Removes any sub behaviours.
	while not _sub_behaviours.empty():
		_remove_sub_behaviour(_sub_behaviours.front())
	
	if _active:
		var target_cell = _terrain.world_to_map(_brain.subject.get_target())
		if _terrain.is_mineral(target_cell):
			
			var pursue : PursueBehaviour = PursueBehaviour.new(false)
			_add_sub_behaviour(pursue)
			
			var destroy_cell = DestroyCellBehaviour.new(target_cell)
			destroy_cell.connect("cell_destroyed", self, "_on_DestroyCellBehaviour_cell_destroyed")
			_add_sub_behaviour(destroy_cell)
			
		else:
			_target_found = false
	else:
		_target_found = false
			

#-------------------------------------------------------------------------------
func _on_DestroyCellBehaviour_cell_destroyed() -> void:
	if _brain.is_debug():
		print("AI " + _brain.subject.name + " destroyed the target cell while harvesting minerals.")
		
	while not _sub_behaviours.empty():
		_remove_sub_behaviour(_sub_behaviours.front())
	
	_target_found = false
	
	
#-------------------------------------------------------------------------------
func _pursue(pos : Vector2) -> void:
	_brain.set_target(pos)
	var pursue : PursueBehaviour = PursueBehaviour.new()
	var _r = pursue.connect("target_reached", self, "_on_PursueBehaviour_target_reached")
	_add_sub_behaviour(pursue)


#-------------------------------------------------------------------------------
func _is_entity_within_range(pos : Vector2, check_range : float) -> bool:
	var range_squared = check_range * check_range
	
	for entity in _entity_sensor.get_entities_in_range():
		if (entity.position - pos).length_squared() <= range_squared:
			return true

	return false


#-------------------------------------------------------------------------------
