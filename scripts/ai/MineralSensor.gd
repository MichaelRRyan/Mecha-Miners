extends Node2D

signal mineral_found(mineral_cell)

var _terrain : TileMap = null

var _scan_direction = Vector2.LEFT
var _scan_rotation = PI * 0.8 # The direction and magnitude of the rotation per second.
var _scan_distance = 100.0
var _scan_segment = 8.0


func _ready():
	var terrain_container = get_tree().get_nodes_in_group("terrain")
	if not terrain_container.empty():
		_terrain = terrain_container.front()


func _process(delta):
	_scan_direction = _scan_direction.rotated(_scan_rotation * delta)
	
	for i in range(0, _scan_distance + 1, _scan_segment):
		var pos = global_position + _scan_direction * i
		var cell_pos = _terrain.world_to_map(pos)
		
		if _terrain.get_cellv(cell_pos) == _terrain.TileType.Crystal:
			emit_signal("mineral_found", cell_pos)
	
	update()


func _draw():
	draw_line(Vector2.ZERO, _scan_direction * _scan_distance, Color.red, 1.0)
