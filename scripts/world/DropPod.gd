extends KinematicBody2D

signal new_velocity()
signal menu_opened()
signal menu_closed()
signal player_entered(player)
signal player_exited(player)

const EXIT_TEXT = "Press 'E' to exit the Drop Pod"
const ENTER_TEXT = "Press 'E' to enter the Drop Pod"

export var gravity = 60.0
export var max_vertical_speed = 400.0

var is_local = false
var player = null
var follow_point = null

var velocity = Vector2.ZERO
var player_in_range = false
var ground_height = -1
var _landed = false
var _driver_inside = true

var _terrain : Terrain = null


# -----------------------------------------------------------------------------
func _ready():
	var terrains = get_tree().get_nodes_in_group("terrain")
	if terrains and not terrains.empty():
		_terrain = terrains.front()


# -----------------------------------------------------------------------------
func _on_PlayerDetector_body_entered(body):
	# Checks if the body is the owner of the drop pod.
	if body == player:
		player_in_range = true
		
		if is_local:
			$InstructionLabel.text = ENTER_TEXT
			$InstructionLabel.show()
	

# ------------------------------------------------------------------------------
func _on_PlayerDetector_body_exited(body):
	# Checks if the body is the owner of the drop pod.
	if body == player:
		player_in_range = false
		
		if is_local:
			$InstructionLabel.hide()


# ------------------------------------------------------------------------------
func _input(event):
	if is_local and _landed and event.is_action_pressed("interact"):
		if _driver_inside:
			emit_signal("menu_closed")
			_driver_inside = false
			emit_signal("player_exited", player)
			player.position = position
			follow_point.set_target(player)
			
		elif player_in_range:
			emit_signal("menu_opened")
			_driver_inside = true
			follow_point.set_target(self)
			emit_signal("player_entered", player)


# ------------------------------------------------------------------------------
func exit():
	if _driver_inside:
		_driver_inside = false
		emit_signal("player_exited", player)
		player.position = position
	

# ------------------------------------------------------------------------------
func enter():
	if player_in_range and not _driver_inside:
		_driver_inside = true
		emit_signal("player_entered", player)


# ------------------------------------------------------------------------------
func _physics_process(delta):
	if not get_tree().paused:
		
		if not _landed:
			if velocity.y > 0.0:
				
				$RayCast2D.force_raycast_update()
				if $RayCast2D.is_colliding():
					var collider = $RayCast2D.get_collider()
					if collider.is_in_group("terrain"):
						ground_height = $RayCast2D.get_collision_point().y
							
				if ground_height != -1:
					var dist = ground_height - position.y
					var interp = 1.0 - (dist / $RayCast2D.cast_to.y)
					velocity.y -= velocity.y * 2 * interp * delta
					
					_handle_rays()
					
		velocity.y += gravity * delta
		
		if velocity.y > max_vertical_speed:
			velocity.y = max_vertical_speed
		
		if not _landed:
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
		player.on_drop_pod_landed()
		
		if is_local:
			$InstructionLabel.text = EXIT_TEXT
			$InstructionLabel.show()
	
	
# ------------------------------------------------------------------------------
