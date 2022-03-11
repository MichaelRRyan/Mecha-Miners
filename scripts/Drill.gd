extends "res://scripts/equipment/Tool.gd"

onready var _raycast = $RayCast2D


# -----------------------------------------------------------------------------
# An override of the Tool base class's activate method.
func activate():
	_raycast.global_position = _holder.global_position
	_raycast.force_raycast_update()
	
	if _raycast.is_colliding():
		var collider = _raycast.get_collider()
		
		if collider.is_in_group("terrain"):
			
			var normal = _raycast.get_collision_normal()
			
			# Gets the terrain as a tilemap.
			var terrain : TileMap = collider
			
			# Works out the position of the tile hit.
			var collision_point = _raycast.get_collision_point()
			var tile_pos = terrain.world_to_map(terrain.to_local(
				collision_point - normal * 0.5))
			
			# Tells the terrain to damage that tile.
			terrain.damage_tile(tile_pos, 0.2)


# -----------------------------------------------------------------------------
func _ready():
	tool_type = Type.DRILL


# -----------------------------------------------------------------------------
