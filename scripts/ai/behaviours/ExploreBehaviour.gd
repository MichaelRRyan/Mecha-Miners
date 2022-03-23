class_name ExploreBehaviour
extends Behaviour

var _terrain : Terrain = null
var _spatial_sensor : Node2D = null
	
	
#-------------------------------------------------------------------------------
func _init():
	_name = "ExploreBehaviour"
	
	
#-------------------------------------------------------------------------------
func _ready() -> void:
	var terrain_container = get_tree().get_nodes_in_group("terrain")
	if not terrain_container.empty():
		_terrain = terrain_container.front()
	
	_spatial_sensor = _brain.find_node("SpatialSensor")
	if _spatial_sensor:
		var _v = _spatial_sensor.connect("new_best", self, "_on_SpatialSensor_new_best")
	
		_brain.set_target(_terrain.map_to_world_centred(_spatial_sensor.get_best_cell()))
		_pursue()
	
	var mineral_sensor : Node2D = _brain.find_node("MineralSensor")
	if mineral_sensor:
		var _v = mineral_sensor.connect("mineral_found", self, "_on_MineralSensor_mineral_found")


#-------------------------------------------------------------------------------
func _on_SpatialSensor_new_best(new_best_cell : Vector2) -> void:
	_brain.set_target(_terrain.map_to_world_centred(new_best_cell))


#-------------------------------------------------------------------------------
func _on_MineralSensor_mineral_found(mineral_cell : Vector2) -> void:
	if _active:
		var behaviour = HarvestMineralsBehaviour.new()
		behaviour.add_spotted_mineral_cell(mineral_cell)
		_brain.add_behaviour(behaviour)


#-------------------------------------------------------------------------------
func _on_Pursue_target_reached() -> void:
	var next_best = _spatial_sensor.get_next_best()
	if next_best != Vector2.ZERO:
		_brain.set_target(_terrain.map_to_world_centred(next_best))
		_pursue()


#-------------------------------------------------------------------------------
func _pursue():
	var pursue = PursueBehaviour.new()
	pursue.connect("target_reached", self, "_on_Pursue_target_reached")
	_brain.add_behaviour(pursue)
