extends TileMap

onready var CrystalShard = preload("res://scenes/CrystalShard.tscn")


enum TileType {
	Empty = -1,
	Solid = 0,
	Crystal = 1,
	Background = 2,
}

# A mapping of tile type to tile max health.
const MAX_TILE_HEALTHS = [
	10.0,
	5.0
]

# The number of damage stages visually displayed.
const DAMAGE_STAGES = 3


# The length of time it takes for a tile to heal by 1
export var tile_heal_time = 1.0


# A dictionary of tile position keys to tile health values.
var damaged_tiles = {}
var crystal_container = null


# -----------------------------------------------------------------------------
func _ready():
	var containers = get_tree().get_nodes_in_group("crystal_container")
	if containers and !containers.empty():
		crystal_container = containers[0]
	else:
		crystal_container = self


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
	var tile_type = get_cellv(tile_position)
	if tile_type != TileType.Empty and tile_type != TileType.Background:
		
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
	var tile_type = get_cellv(tile_position)
	var damage = damaged_tiles[tile_position].damage
	var damage_stage = floor(damage / MAX_TILE_HEALTHS[tile_type] * DAMAGE_STAGES)
	$DamageIndicators.set_cellv(tile_position, damage_stage)


# -----------------------------------------------------------------------------
func __destroy_tile(tile_position : Vector2):
	
	var type = get_cellv(tile_position)
	
	if TileType.Crystal == type:
		spawn_crystals(tile_position * 16.0 + Vector2(8.0, 9.0), 
			randi() % 5 + 1)
	
	# Removes the cell and updates the surrounding cells.
	if tile_position.y > 10:
		set_cellv(tile_position, TileType.Background)
	else:
		set_cellv(tile_position, TileType.Empty)
	update_bitmask_area(tile_position)
	
	# Removes the damage information and visual.
	damaged_tiles.erase(tile_position)
	$DamageIndicators.set_cellv(tile_position, -1)


# -----------------------------------------------------------------------------
func spawn_crystals(_position, amount):
	for _i in range(amount):
		var crystal = CrystalShard.instance()
		crystal_container.add_child(crystal)
		crystal.position = _position
		crystal.velocity = Vector2(rand_range(-50, 50), rand_range(-100, -10))
		

# -----------------------------------------------------------------------------
