class_name ExploreBehaviour
extends Behaviour

var _terrain : Terrain = null
var _spatial_sensor : Node2D = null
	
	
#-------------------------------------------------------------------------------
func _init():
	_name = "ExploreBehaviour"
	_priority = 1
	
	
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


#-------------------------------------------------------------------------------
func _on_SpatialSensor_new_best(new_best_cell : Vector2) -> void:
	if _brain.get_highest_priority() == self:
		_brain.set_target(_terrain.map_to_world_centred(new_best_cell))


#-------------------------------------------------------------------------------
func _on_Pursue_target_reached() -> void:
	if _brain.get_highest_priority() == self:
		var next_best = _spatial_sensor.get_best_cell()
		if next_best != _spatial_sensor.INVALID_CELL:
			_brain.set_target(_terrain.map_to_world_centred(next_best))
			_pursue()


#-------------------------------------------------------------------------------
func _pursue():
	var pursue = PursueBehaviour.new()
	pursue.connect("target_reached", self, "_on_Pursue_target_reached")
	_brain.add_behaviour(pursue)
