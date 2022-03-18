class_name HarvestMineralsBehaviour
extends Behaviour

var _terrain : Terrain = null
var _spotted_mineral_cells = []
var _spotted_mineral_items = []


#-------------------------------------------------------------------------------
func add_spotted_mineral_cell(mineral_cell : Vector2) -> void:
	_spotted_mineral_cells.append(mineral_cell)


#-------------------------------------------------------------------------------
func add_spotted_mineral_item(mineral_item : Node2D) -> void:
	_spotted_mineral_items.append(mineral_item)


#-------------------------------------------------------------------------------
func _ready() -> void:
	_name = "HarvestMineralsBehaviour"
	
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
		
		# Checks for spotted mineral items to collect.
		for mineral_item in _spotted_mineral_items:
			# Checks the item still exists.
			if mineral_item != null and is_instance_valid(mineral_item):
				_pursue(mineral_item.global_position)
				mineral_found = true
				break
		
		# If no items found, checks for spotted mineral tiles.
		if not mineral_found:
			for mineral_cell in _spotted_mineral_cells:
				# Checks the cell is still a mineral.
				if _terrain.is_mineral(mineral_cell):
					_pursue(_terrain.map_to_world_centred(mineral_cell))
					mineral_found = true
					break
			
		# If no mineral tiles or items could be found, return from behaviour.
		if not mineral_found:
			_brain.pop_behaviour()


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
