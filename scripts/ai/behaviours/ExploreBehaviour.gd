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
		var _v = _spatial_sensor.connect("new_furthest", self, "_on_SpatialSensor_new_furthest")
	
		_brain.set_target(_terrain.map_to_world_centred(_spatial_sensor._furthest_cell))
		_pursue()


#-------------------------------------------------------------------------------
func _on_SpatialSensor_new_furthest(furthest_cell : Vector2) -> void:
	_brain.set_target(_terrain.map_to_world_centred(furthest_cell))


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
