extends KinematicBody2D

export var speed = 250.0
export var max_distance = 200.0

var velocity = Vector2.ZERO
var start_position = Vector2.ZERO


# -----------------------------------------------------------------------------
func _ready():
	velocity = Vector2(cos(rotation), sin(rotation)) * speed
	start_position = position


# -----------------------------------------------------------------------------
func _physics_process(_delta):
	var _result = move_and_slide(velocity)
	
	# Loops through all/any collisions from the last movement.
	for i in range(get_slide_count()):
		
		# Gets the collision info.
		var collision = get_slide_collision(i)
		
		# Checks if the colliding node is in the "terrain" group.
		if collision.collider.is_in_group("terrain"):
			
			# Gets the terrain as a tilemap.
			var terrain : TileMap = collision.collider
			
			# Works out the position of the tile hit.
			var tile_pos = terrain.world_to_map(terrain.to_local(position))
			
			tile_pos -= Vector2(round(collision.normal.x), 
								round(collision.normal.y))
			
			# Tells the terrain to damage that tile.
			terrain.damage_tile(tile_pos, 1)
		
			# Delete the bullet and stop looping.
			queue_free()
			break;
		

	if (start_position - position).length_squared() > max_distance * max_distance:
		queue_free()


# -----------------------------------------------------------------------------
