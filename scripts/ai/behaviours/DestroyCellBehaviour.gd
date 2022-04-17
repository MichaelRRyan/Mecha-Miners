class_name DestroyCellBehaviour
extends Behaviour

signal cell_destroyed()


var _terrain = null

var _target_cell = Vector2.ZERO
var _previous_target = null


#-------------------------------------------------------------------------------
func _init(target_cell : Vector2) -> void:
	_name = "DestroyCellBehaviour"
	_priority = 1
	_target_cell = target_cell
	
	
	
#-------------------------------------------------------------------------------
func _ready() -> void:
	var terrain_container = get_tree().get_nodes_in_group("terrain")
	if not terrain_container.empty():
		_terrain = terrain_container.front()

	_previous_target = _brain.subject.get_target()
	_brain.subject.set_target(_terrain.map_to_world_centred(_target_cell))
	
	var equipment_count = _brain.subject.get_drill_count() + _brain.subject.get_gun_count()
	if equipment_count == 0:
		print_debug("No suitable equipment found.")
		_brain.subject.set_target(_previous_target)
		_brain.pop_behaviour()


#-------------------------------------------------------------------------------
func _process(_delta : float) -> void:
	if _active:
		_brain.subject.mine()
		_brain.subject.attack()
		
		if _terrain.is_empty(_target_cell):
			_brain.subject.set_target(_previous_target)
			set_active(false)
			emit_signal("cell_destroyed")


#-------------------------------------------------------------------------------
