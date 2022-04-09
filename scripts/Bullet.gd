extends Node2D

onready var HitParticleScene = preload("res://scenes/BulletHitParticle.tscn")

export var damage : float = 1.0
export var speed : float = 250.0
export var max_distance : float = 200.0
export var width : float = 12.0

# The peer id to ignore in collisions.
var ignore_rid

var velocity = Vector2.ZERO
var start_position = null
onready var raycast = $RayCast2D


# -----------------------------------------------------------------------------
func _ready():
	velocity = Vector2(cos(rotation), sin(rotation)) * speed
	
	raycast.add_exception_rid(ignore_rid)
	
	if start_position:
		raycast.global_position = start_position
		raycast.cast_to.x = (position - start_position).length()
		__check_for_collision()
		raycast.position = Vector2.ZERO
	
	start_position = position


# -----------------------------------------------------------------------------
func _physics_process(delta):
	
	var frame_movement = velocity * delta
	raycast.cast_to.x = max(width, frame_movement.length())
	__check_for_collision()
		
	position += frame_movement

	if (start_position - position).length_squared() > max_distance * max_distance:
		queue_free()


# -----------------------------------------------------------------------------
func __check_for_collision():
	raycast.force_raycast_update()
	
	if raycast.is_colliding():
		var collider = raycast.get_collider()
		
		if collider.get_parent() != null and collider.get_parent().is_in_group("terrain"):
			collider = collider.get_parent()
			
			var normal = raycast.get_collision_normal()
			
			# Gets the terrain as a tilemap.
			var terrain : Terrain = collider
			
			# Works out the position of the tile hit.
			var collision_point = raycast.get_collision_point()
			var tile_pos = terrain.world_to_map(terrain.to_local(
				collision_point - normal * 0.5))
			
			# Tells the terrain to damage that tile.
			terrain.damage_tile(tile_pos, 1)
		
			position = collision_point
			__on_impact()
			
		elif collider.is_in_group("player"):
			__on_player_impact(collider)
	

# -----------------------------------------------------------------------------
func __on_impact():
	queue_free()
	create_hit_particles()
	

# -----------------------------------------------------------------------------
func __on_player_impact(player):
	# If online and the collided player is not the ignored peer id.
	#if Network.is_online: # and player.get_network_master() != ignore_id:
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
		particle.position = global_position
		var impact_direction = -Vector3(cos(global_rotation), 
										sin(global_rotation), 0.0)
		particle.process_material.direction = impact_direction


# -----------------------------------------------------------------------------
