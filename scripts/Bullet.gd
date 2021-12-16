extends KinematicBody2D

onready var HitParticleScene = preload("res://scenes/BulletHitParticle.tscn")

export var damage : float = 1.0
export var speed : float = 250.0
export var max_distance : float = 200.0
export var width : float = 6.0

# The peer id to ignore in collisions.
var ignore_id

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
		
			# Call on_impact stop looping.
			__on_impact()
			break;
		

	if (start_position - position).length_squared() > max_distance * max_distance:
		queue_free()


# -----------------------------------------------------------------------------
func _on_PlayerDetector_body_entered(body):
	if body.is_in_group("player"):
		__on_player_impact(body)


# -----------------------------------------------------------------------------
func __on_impact():
	queue_free()
	create_hit_particles()
	

# -----------------------------------------------------------------------------
func __on_player_impact(player):
	# If online and the collided player is not the ignored peer id.
	if Network.is_online and player.get_network_master() != ignore_id:
		if player.has_method("take_damage"):
			player.take_damage(damage)
		
		queue_free()
		create_hit_particles()


# -----------------------------------------------------------------------------
func create_hit_particles():
	var containers = get_tree().get_nodes_in_group("particle_container")
	if containers and not containers.empty():
		var container = containers[0]
		var particle = HitParticleScene.instance()
		container.add_child(particle)
		particle.position = global_position + velocity.normalized() * 5.0
		var impact_direction = -Vector3(cos(global_rotation), 
										sin(global_rotation), 0.0)
		particle.process_material.direction = impact_direction


# -----------------------------------------------------------------------------
