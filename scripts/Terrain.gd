extends Node2D
class_name Terrain

onready var CrystalShard = preload("res://scenes/CrystalShard.tscn")


enum TileType {
	Empty = -1,
	Solid = 0,
	Unbreakable = 1,
	Crystal = 2,
	Background = 6,
}

# A mapping of tile type to tile max health.
const MAX_TILE_HEALTHS = [
	10.0, # Solid
	100000000000.0, # Unbreakable
	5.0, # Crystal
]

# The number of damage stages visually displayed.
const DAMAGE_STAGES = 3


# The length of time it takes for a tile to heal by 1
export var tile_heal_time = 1.0


# A dictionary of tile position keys to tile health values.
var damaged_tiles = {}
var crystal_container = null
var _pathfinding : AStar2D = AStar2D.new()
onready var _foreground = get_node("Foreground")
	
	
# -----------------------------------------------------------------------------
func clear() -> void:
	_foreground.clear()


# -----------------------------------------------------------------------------
func is_empty(cell_position : Vector2) -> bool:
	var type = _foreground.get_cellv(cell_position)
	return (TileType.Empty == type
		or TileType.Background == type)


# -----------------------------------------------------------------------------
func is_mineral(cell_position : Vector2) -> bool:
	return TileType.Crystal == _foreground.get_cellv(cell_position)


# -----------------------------------------------------------------------------
func world_to_map(world_position : Vector2) -> Vector2:
	return _foreground.world_to_map(world_position)


# -----------------------------------------------------------------------------
func map_to_world(cell_position : Vector2) -> Vector2:
	return _foreground.map_to_world(cell_position)


# -----------------------------------------------------------------------------
func map_to_world_centred(cell_position : Vector2) -> Vector2:
	return _foreground.map_to_world(cell_position) + (get_cell_size() * 0.5)


# -----------------------------------------------------------------------------
func get_pathfinding() -> AStar2D:
	return _pathfinding
	
	
# -----------------------------------------------------------------------------
func get_cell_size() -> Vector2:
	return _foreground.cell_size


# -----------------------------------------------------------------------------
func set_background(x : int, y : int) -> void:
	$Background.set_cell(x, y, TileType.Background)


# -----------------------------------------------------------------------------
func _ready():
	var containers = get_tree().get_nodes_in_group("crystal_container")
	if containers and !containers.empty():
		crystal_container = containers[0]
	else:
		crystal_container = self
		
	_generate_pathfinding_grid()


# -----------------------------------------------------------------------------
func _physics_process(_delta):
	var deletion_queue = []
	
	# Loops through all recently damaged tiles.
	for tile_position in damaged_tiles:
		var tile = damaged_tiles[tile_position]
		
		# Checks if the tile was last hit more than a second ago.
		if tile.last_hit < OS.get_unix_time() - tile_heal_time:
			tile.damage -= 1.0
			tile.last_hit = OS.get_unix_time()
			
			# If the tile is healed fully, remove the damage indicator and info.
			if tile.damage <= 0.0:
				$DamageIndicators.set_cellv(tile_position, TileType.Empty)
				deletion_queue.append(tile_position)
			else:
				__set_damage_indicator(tile_position)
	
	# Delete all the tiles in the queue.
	for tile_position in deletion_queue:
		damaged_tiles.erase(tile_position)


# -----------------------------------------------------------------------------
func damage_tile(tile_position : Vector2, damage : float):
	# If the tile is not empty.
	var tile_type = _foreground.get_cellv(tile_position)
	if (tile_type != TileType.Empty 
		and tile_type != TileType.Background
		and tile_type != TileType.Unbreakable):
		
		# If the tile has been damaged recently.
		if damaged_tiles.has(tile_position):
			var tile = damaged_tiles[tile_position]
			
			# Add the damage and update the timestamp.
			tile.damage += damage
			tile.last_hit = OS.get_unix_time()
			
			# If the damage is greater than or equal to the health, remove it.
			if tile.damage >= MAX_TILE_HEALTHS[tile_type]:
				__destroy_tile(tile_position)
				
			else:
				__set_damage_indicator(tile_position)
		else:
			# Creates a new tile damage info object.
			damaged_tiles[tile_position] = {
				last_hit = OS.get_unix_time(),
				damage = damage
			}
			
			__set_damage_indicator(tile_position)


# -----------------------------------------------------------------------------
func __set_damage_indicator(tile_position : Vector2):
	var tile_type = _foreground.get_cellv(tile_position)
	var damage = damaged_tiles[tile_position].damage
	var damage_stage = floor(damage / MAX_TILE_HEALTHS[tile_type] * DAMAGE_STAGES)
	$DamageIndicators.set_cellv(tile_position, damage_stage)


# -----------------------------------------------------------------------------
func __destroy_tile(tile_position : Vector2):
	
	var type = _foreground.get_cellv(tile_position)
	
	if TileType.Crystal == type:
		spawn_crystals(tile_position * 16.0 + Vector2(8.0, 9.0), 
			randi() % 5 + 1)
	
	# Removes the cell and updates the surrounding cells.
	_foreground.set_cellv(tile_position, TileType.Empty)
	set_background(tile_position.x, tile_position.y)
	_foreground.update_bitmask_area(tile_position)
	
	# Removes the damage information and visual.
	damaged_tiles.erase(tile_position)
	$DamageIndicators.set_cellv(tile_position, -1)
	
	var new_point = _pathfinding.get_available_point_id()
	var centred_pos = map_to_world_centred(tile_position)
	_pathfinding.add_point(new_point, centred_pos)
	_update_pathfinding_connections(tile_position, new_point)


# -----------------------------------------------------------------------------
func spawn_crystals(_position, amount):
	for _i in range(amount):
		var crystal = CrystalShard.instance()
		crystal_container.add_child(crystal)
		crystal.position = _position
		crystal.velocity = Vector2(rand_range(-50, 50), rand_range(-100, -10))
		

# -----------------------------------------------------------------------------
func _generate_pathfinding_grid() -> void:
	for x in range(-100, 100):
		for y in range(-50, 100):
			
			if _foreground.get_cell(x, y) == TileType.Empty:		
				var new_point = _pathfinding.get_available_point_id()
				_pathfinding.add_point(new_point, map_to_world_centred(Vector2(x, y)))
				
				if _foreground.get_cell(x - 1, y) == TileType.Empty:
					var other_point = _pathfinding.get_closest_point(map_to_world_centred(Vector2(x - 1, y)))
					if other_point != new_point:
						_pathfinding.connect_points(other_point, new_point)
				
				if _foreground.get_cell(x, y - 1) == TileType.Empty:
					var other_point = _pathfinding.get_closest_point(map_to_world_centred(Vector2(x, y - 1)))
					if other_point != new_point:
						_pathfinding.connect_points(other_point, new_point)


# -----------------------------------------------------------------------------
func _update_pathfinding_connections(cell_position : Vector2, new_point_id : int) -> void:
	var dir = Vector2.RIGHT
	
	for _i in range(4):
		var next_cell = cell_position + dir
		
		if _foreground.get_cellv(next_cell) == TileType.Empty or _foreground.get_cellv(next_cell) == TileType.Background:
			var other_point = _pathfinding.get_closest_point(map_to_world_centred(next_cell))
			if other_point != new_point_id:
				_pathfinding.connect_points(other_point, new_point_id)
		
		dir = Vector2(-dir.y, dir.x)
