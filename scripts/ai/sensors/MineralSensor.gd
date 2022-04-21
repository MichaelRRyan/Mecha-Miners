extends Node2D

signal mineral_found(mineral_cell)

# Dependencies.
onready var _terrain : Terrain = Utility.get_dependency("terrain")
var _brain : AIBrain = null

var _scan_direction = Vector2.LEFT
var _scan_rotation = PI * 2 # The direction and magnitude of the rotation per second.
var _scan_distance = 160.0
var _scan_segment = 8.0

var _minerals_found = []


#-------------------------------------------------------------------------------
func get_minerals_found() -> Array:
	return _minerals_found
	
	
#-------------------------------------------------------------------------------
func erase_cell_reference(cell : Vector2) -> void:
	_minerals_found.erase(cell)


#-------------------------------------------------------------------------------
func _ready():
	if _terrain == null:
		set_process(false)
	
	# Gets the parent as the brain if it's an AI brain.
	var parent = get_parent()
	if parent != null and parent is AIBrain:
		_brain = parent 

		
#-------------------------------------------------------------------------------
func _process(delta):
	_scan_direction = _scan_direction.rotated(_scan_rotation * delta)
	
	for i in range(0, _scan_distance + 1, _scan_segment):
		var pos = global_position + _scan_direction * i
		var cell_pos = _terrain.world_to_map(pos)
		
		if _terrain.is_mineral(cell_pos):
			_minerals_found.append(cell_pos)
			emit_signal("mineral_found", cell_pos)
	
	update()

		
#-------------------------------------------------------------------------------
func _draw():
	if _brain.is_debug():
		draw_line(Vector2.ZERO, _scan_direction * _scan_distance, Color.red, 1.0)

		
#-------------------------------------------------------------------------------
