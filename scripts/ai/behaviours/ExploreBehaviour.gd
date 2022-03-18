class_name ExploreBehaviour
extends Behaviour

var _terrain : Terrain = null
	
	
#-------------------------------------------------------------------------------
func _ready() -> void:
	_name = "ExploreBehaviour"
	
	var terrain_container = get_tree().get_nodes_in_group("terrain")
	if not terrain_container.empty():
		_terrain = terrain_container.front()
	
	var spatial_sensor : Node2D = _brain.find_node("SpatialSensor")
	if spatial_sensor:
		var _v = spatial_sensor.connect("new_furthest", self, "_on_SpatialSensor_new_furthest")
	
		_brain.set_target(_terrain.map_to_world_centred(spatial_sensor._furthest_cell))
		_brain.add_behaviour(PursueBehaviour.new())


#-------------------------------------------------------------------------------
func _on_SpatialSensor_new_furthest(furthest_cell : Vector2) -> void:
	_brain.set_target(_terrain.map_to_world_centred(furthest_cell))


#-------------------------------------------------------------------------------
