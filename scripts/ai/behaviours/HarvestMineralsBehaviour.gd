class_name HarvestMineralsBehaviour
extends Behaviour

const AVOID_ENTITY_RANGE = 128.0

var _terrain : Terrain = null
var _spotted_mineral_cells = []
var _spotted_mineral_items = []


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


#-------------------------------------------------------------------------------
func _on_MineralSensor_mineral_found(mineral_position : Vector2) -> void:
	_spotted_mineral_cells.append(mineral_position)
	
	
#-------------------------------------------------------------------------------
func _on_ItemSensor_mineral_found(mineral_object : Node2D) -> void:
	_spotted_mineral_items.append(mineral_object)


#-------------------------------------------------------------------------------
func _process(_delta : float) -> void:
	if _active:
		var mineral_found = false
		var mineral_pos = Vector2.ZERO
		var closest_dist = Vector2.ZERO
		
		# Checks for spotted mineral items to collect.
		for mineral_item in _spotted_mineral_items:
			# Checks the item still exists.
			if mineral_item != null and is_instance_valid(mineral_item):
				
				var pos = mineral_item.global_position
				if not _is_entity_within_range(pos, AVOID_ENTITY_RANGE):
					var dist = (pos - global_position).length_squared()
					
					# If another mineral has not been found yet, or this one is closer.
					if not mineral_found or dist < closest_dist:
						mineral_pos = pos
						closest_dist = dist
						mineral_found = true
		
		# If no items found, checks for spotted mineral tiles.
		if not mineral_found:
			for mineral_cell in _spotted_mineral_cells:
				# Checks the cell is still a mineral and has not been destroyed.
				if _terrain.is_mineral(mineral_cell):
					
					var pos = _terrain.map_to_world_centred(mineral_cell)
					if not _is_entity_within_range(pos, AVOID_ENTITY_RANGE):
						var dist = (pos - global_position).length_squared()
						
						if not mineral_found or dist < closest_dist:
							mineral_pos = _terrain.map_to_world_centred(mineral_cell)
							closest_dist = dist
							mineral_found = true
			
		# If no mineral tiles or items could be found, return from behaviour.
		if not mineral_found:
			_brain.pop_behaviour()
		else:
			_pursue(mineral_pos)


#-------------------------------------------------------------------------------
func _on_PursueBehaviour_target_reached() -> void:
	if _active:
		var target_cell = _terrain.world_to_map(_brain.subject.get_target())
		if _terrain.is_mineral(target_cell):
			_brain.add_behaviour(DestroyCellBehaviour.new(target_cell))


#-------------------------------------------------------------------------------
func _pursue(pos : Vector2) -> void:
	_brain.set_target(pos)
	var pursue : PursueBehaviour = PursueBehaviour.new()
	var _r = pursue.connect("target_reached", self, "_on_PursueBehaviour_target_reached")
	_brain.add_behaviour(pursue)


#-------------------------------------------------------------------------------
func _is_entity_within_range(pos : Vector2, check_range : float) -> bool:
	var range_squared = check_range * check_range
	
	for entity in _brain.get_entities_in_range():
		if (entity.position - pos).length_squared() <= range_squared:
			return true

	return false


#-------------------------------------------------------------------------------
