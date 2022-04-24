extends KinematicBody2D

signal new_velocity()
signal menu_toggled()

export var gravity = 60.0
export var max_vertical_speed = 400.0

var velocity = Vector2.ZERO
var player_in_range = false
var ground_height = -1
var _landed = false

var _terrain : Terrain = null


# -----------------------------------------------------------------------------
func _on_PlayerDetector_body_entered(body):
	# Checks if the body is a non remote player.
	if (body.is_in_group("player") 
		and (not Network.is_online or body.is_network_master())):
			player_in_range = true
	
	var terrains = get_tree().get_nodes_in_group("terrain")
	if terrains and not terrains.empty():
		_terrain = terrains.front()


# ------------------------------------------------------------------------------
func _on_PlayerDetector_body_exited(body):
	# Checks if the body is a non remote player.
	if (body.is_in_group("player") 
		and (not Network.is_online or body.is_network_master())):
			player_in_range = false


# ------------------------------------------------------------------------------
func _input(event):
	if event.is_action_pressed("interact"):
		emit_signal("menu_toggled")


# ------------------------------------------------------------------------------
func _physics_process(delta):
	if not get_tree().paused:
		
		if not _landed:
			if velocity.y > 0.0:
				if ground_height == -1:
					$RayCast2D.force_raycast_update()
					if $RayCast2D.is_colliding():
						var collider = $RayCast2D.get_collider()
						if collider.is_in_group("terrain"):
							ground_height = $RayCast2D.get_collision_point().y
				else:
					var dist = ground_height - position.y
					var interp = 1.0 - (dist / $RayCast2D.cast_to.y)
					velocity.y -= velocity.y * 2 * interp * delta
					
					_handle_rays()
					
		velocity.y += gravity * delta
		
		if velocity.y > max_vertical_speed:
			velocity.y = max_vertical_speed
		
		emit_signal("new_velocity", velocity)
		velocity = move_and_slide(velocity, Vector2.UP)
		

# ------------------------------------------------------------------------------
func _handle_rays():
	var hitting = []
	for raycast in $Raycasts.get_children():
		raycast.force_raycast_update()
		if raycast.is_colliding() and raycast.get_collider().is_in_group("terrain"):
			hitting.append(raycast)
	
	if _terrain != null and not hitting.empty() and hitting.size() < 4:
		for raycast in hitting:
			var pos = raycast.global_position + raycast.cast_to
			var cell = _terrain.world_to_map(pos)
			_terrain.damage_tile(cell, 1000)
			
	elif hitting.size() == 4:
		_landed = true
		$ParticlesLarge.emitting = false
		$ParticlesSmall.emitting = false
	
	
# ------------------------------------------------------------------------------
