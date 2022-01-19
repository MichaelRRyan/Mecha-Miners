extends Sprite

export var automatic = true
var holder_rid = null

onready var _raycast = $RayCast2D

# -----------------------------------------------------------------------------
func activate():
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
