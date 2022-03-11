class_name HarvestMineralsBehaviour
extends Behaviour

var _terrain : Terrain = null
var _spotted_minerals = []


#-------------------------------------------------------------------------------
func _init(mineral_cell : Vector2) -> void:
	_spotted_minerals.append(mineral_cell)


#-------------------------------------------------------------------------------
func _ready() -> void:
	var terrain_container = get_tree().get_nodes_in_group("terrain")
	if not terrain_container.empty():
		_terrain = terrain_container.front()
	
	var sensor : Node2D = _brain.find_node("MineralSensor")
	if sensor:
		var _v = sensor.connect("mineral_found", self, "_on_MineralSensor_mineral_found")


#-------------------------------------------------------------------------------
func _on_MineralSensor_mineral_found(mineral_position : Vector2) -> void:
	_spotted_minerals.append(mineral_position)
	

#-------------------------------------------------------------------------------
func _process(_delta : float) -> void:
	var mineral_found = false
	
	for mineral in _spotted_minerals:
		# Checks the cell is still a mineral.
		if _terrain.is_mineral(mineral):
			_brain.set_target(_terrain.map_to_world_centred(mineral))
			var pursue : PursueBehaviour = PursueBehaviour.new()
			var _r = pursue.connect("target_reached", self, "_on_PursueBehaviour_target_reached")
			_brain.add_behaviour(pursue)
			mineral_found = true
			break
		
	if not mineral_found:
		_brain.pop_behaviour()


#-------------------------------------------------------------------------------
func _on_PursueBehaviour_target_reached() -> void:
	var target_cell = _terrain.world_to_map(_brain.subject.get_target())
	_brain.add_behaviour(DestroyCellBehaviour.new(target_cell))


#-------------------------------------------------------------------------------
func get_class() -> String:
	return "HarvestMineralsBehaviour"


#-------------------------------------------------------------------------------
