class_name DestroyCellBehaviour
extends Behaviour

signal cell_destroyed()


var _terrain = null

var _target_cell = Vector2.ZERO


#-------------------------------------------------------------------------------
func _init() -> void:
	_name = "DestroyCellBehaviour"
	
	
#-------------------------------------------------------------------------------
# Updates the target cell to match the target.
func update_target_cell() -> void:
	_target_cell = _terrain.world_to_map(_brain.subject.get_target())
	
	
#-------------------------------------------------------------------------------
func _ready() -> void:
	var terrain_container = get_tree().get_nodes_in_group("terrain")
	if not terrain_container.empty():
		_terrain = terrain_container.front()

	update_target_cell()
	
	var equipment_count = _brain.subject.get_drill_count() + _brain.subject.get_gun_count()
	if equipment_count == 0:
		print_debug("No suitable equipment found.")
		set_active(false)


#-------------------------------------------------------------------------------
func _process(_delta : float) -> void:
	if _active:
		_brain.subject.mine()
		_brain.subject.attack()
		
		if _terrain.is_empty(_target_cell):
			set_active(false)
			emit_signal("cell_destroyed")


#-------------------------------------------------------------------------------
