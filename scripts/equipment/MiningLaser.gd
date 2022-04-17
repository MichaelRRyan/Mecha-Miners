extends Tool

onready var _raycast : RayCast2D = $RayCast2D
var _mining = true
var _mining_last_frame = true
var _mine_point = Vector2.ZERO


# -----------------------------------------------------------------------------
# An override of the Tool base class's activate method.
func activate():
	var target = _holder.get_target()
	var dist = target - global_position
	
	if _holder.position.x < target.x:
		position.x = abs(position.x)
	else:
		position.x = -abs(position.x)
	
	_raycast.cast_to = dist
	_raycast.force_raycast_update()
	
	if _raycast.is_colliding():
		var collider = _raycast.get_collider()
		
		if collider.get_parent() != null and collider.get_parent().is_in_group("terrain"):
			collider = collider.get_parent()
			
			var normal = _raycast.get_collision_normal()
			
			# Gets the terrain as a tilemap.
			var terrain : Terrain = collider
			
			# Works out the position of the tile hit.
			var collision_point = _raycast.get_collision_point()
			var tile_pos = terrain.world_to_map(terrain.to_local(
				collision_point - normal * 0.5))
				
			_mine_point = collision_point - global_position
			
			# Tells the terrain to damage that tile.
			terrain.damage_tile(tile_pos, 0.2)
			
			_mining = true
			update()


# -----------------------------------------------------------------------------
func _draw():
	if _mining or _mining_last_frame:
		draw_line(Vector2.ZERO, _mine_point, Color.red, 1.5)


# -----------------------------------------------------------------------------
func _process(_delta):
	_mining_last_frame = _mining
	_mining = false
	update()


# -----------------------------------------------------------------------------
func _ready():
	tool_type = Type.DRILL


# -----------------------------------------------------------------------------
