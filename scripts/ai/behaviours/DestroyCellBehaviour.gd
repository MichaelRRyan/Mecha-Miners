class_name DestroyCellBehaviour
extends Behaviour

signal cell_destroyed()


var _terrain = null

var _target_cell = Vector2.ZERO
var _previous_target = null
var _mech_arms = null


#-------------------------------------------------------------------------------
func get_class() -> String:
	return "DestroyCellBehaviour"


#-------------------------------------------------------------------------------
func _init(target_cell : Vector2) -> void:
	_target_cell = target_cell
	
	
#-------------------------------------------------------------------------------
func _ready() -> void:
	var terrain_container = get_tree().get_nodes_in_group("terrain")
	if not terrain_container.empty():
		_terrain = terrain_container.front()

	_previous_target = _brain.subject.get_target()
	_brain.subject.set_target(_terrain.map_to_world_centred(_target_cell))
	
	_mech_arms = _brain.subject.find_node("Arms")
	if _mech_arms == null:
		print_debug("Unable to find mech arms node")
		_brain.subject.set_target(_previous_target)
		_brain.pop_behaviour()


#-------------------------------------------------------------------------------
func _process(_delta : float) -> void:
	_mech_arms.equipped1.activate()
	_mech_arms.equipped2.activate()
	
	var type = _terrain.get_cellv(_target_cell)
	if type == _terrain.TileType.Empty or type == _terrain.TileType.Background:
		_brain.subject.set_target(_previous_target)
		_brain.pop_behaviour()
		emit_signal("cell_destroyed")


#-------------------------------------------------------------------------------
