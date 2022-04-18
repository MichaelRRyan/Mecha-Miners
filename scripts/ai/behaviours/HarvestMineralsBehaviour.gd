class_name HarvestMineralsBehaviour
extends Behaviour

const AVOID_ENTITY_RANGE = 64.0

var _terrain : Terrain = null
var _mineral_sensor = null
var _entity_sensor = null
var _destroy_cell_behaviour = null

var _target_found = false
var _pursue_created = false
var _harvesting = false
var _collect_items_when_ready = false


#-------------------------------------------------------------------------------
func _init():
	_name = "HarvestMineralsBehaviour"
	_priority = 10


#-------------------------------------------------------------------------------
func _ready() -> void:
	var terrain_container = get_tree().get_nodes_in_group("terrain")
	if not terrain_container.empty():
		_terrain = terrain_container.front()
	
	var item_sensor : Node2D = _brain.find_node("ItemSensor")
	if item_sensor:
		var _v = item_sensor.connect("item_found", self, "_on_ItemSensor_item_found")
		
	_mineral_sensor = _brain.find_node("MineralSensor")
	if _mineral_sensor == null:
		set_process(false)
		_brain.pop_behaviour()
		
	_entity_sensor = _brain.find_node("EntitySensor")
	if _entity_sensor == null:
		set_process(false)
		_brain.pop_behaviour()
	
	
#-------------------------------------------------------------------------------
func _on_ItemSensor_item_found(_item_obj : Node2D) -> void:
	if _active:
		_collect_items_when_ready = true


#-------------------------------------------------------------------------------
func _process(_delta : float) -> void:
	if _active and not _target_found:
		
		if _collect_items_when_ready:
			_collect_items_when_ready = false
			_brain.add_behaviour(CollectItemsBehaviour.new())
		
		else:
			var mineral_found = false
			var mineral_pos = Vector2.ZERO
			var closest_dist = 0
			
			var deletion_queue = []
			
			for mineral_cell in _mineral_sensor.get_minerals_found():
				
				# Checks the cell is still a mineral and has not been destroyed.
				if _terrain.is_mineral(mineral_cell):
					
					# Checks there's no other entity too close to the cell.
					var pos = _terrain.map_to_world_centred(mineral_cell)
					if not _entity_sensor.is_entity_within_range_of(pos, AVOID_ENTITY_RANGE):
						
						var dist = (pos - global_position).length_squared()
						if not mineral_found or dist < closest_dist:
							mineral_pos = pos
							closest_dist = dist
							mineral_found = true
				else:
					deletion_queue.append(mineral_cell)
					
			for cell in deletion_queue:
				_mineral_sensor.erase_cell_reference(cell)
				
			# If no mineral tiles could be found, returns from behaviour.
			if not mineral_found:
				_brain.pop_behaviour()
				
			else:
				if _brain.is_debug():
					print("AI " + _brain.subject.name + " found target in " + get_class() + ".")
				
				_target_found = true
				_pursue(mineral_pos)
			
			
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
	if not _harvesting:
		
		if _brain.is_debug():
			print("AI " + _brain.subject.name + " target reached in " + get_class() + ".")
		
		var target_cell = _terrain.world_to_map(_brain.subject.get_target())
		if _terrain.is_mineral(target_cell):
			_harvesting = true
			
			if _destroy_cell_behaviour == null:
				_destroy_cell_behaviour = DestroyCellBehaviour.new()
				_destroy_cell_behaviour.connect("cell_destroyed", self, "_on_DestroyCellBehaviour_cell_destroyed")
				_add_sub_behaviour(_destroy_cell_behaviour)
			else:
				_destroy_cell_behaviour.set_active(true)
				_destroy_cell_behaviour.update_target_cell()
			
		else:
			_target_found = false
			

#-------------------------------------------------------------------------------
func _on_DestroyCellBehaviour_cell_destroyed() -> void:
	if _brain.is_debug():
		print("AI " + _brain.subject.name + " destroyed the target cell while harvesting minerals.")
	
	_destroy_cell_behaviour.set_active(false)
	_target_found = false
	_harvesting = false


#-------------------------------------------------------------------------------
