extends KinematicBody2D

tool

signal died()
signal damage_taken(health, source)
signal crystal_amount_changed(total_crystals)
signal new_velocity(velocity)
signal respawn_complete()
signal sync_began(sync_data)
signal sync_data_recieved(sync_data)

export var health : float = 5.0

# -- Configurable Properties --
export(float) var _max_speed = 50.0 setget set_max_speed # Pixels / Second
export(float) var _time_to_max_speed = 0.1 setget set_time_to_max_speed # Seconds
export(float) var _time_to_full_stop = 0.1 setget set_time_to_full_stop # Seconds
export(float) var _jump_height = 32.0 setget set_jump_height # Pixels
export(float) var _time_to_jump_peak = 0.6 setget set_time_to_jump_peak # Seconds

# -- Auto Configured Properties --
var _acceleration = 0.0
var _deceleration = 0.0
var _jump_speed = 0.0
var _gravity_acceleration = 0.0
var velocity = Vector2.ZERO

# -- Private Variables --
var respawning = false
var was_on_floor = false
var _target = Vector2.ZERO
var direction : float = 0.0
var _vacuumed_items = []
var _item_vacuum_speed = 5.0

var drop_pod = null
var inventory : Inventory = Inventory.new()
var equipped : Array = [] # Array<Tool>
var _drills : Array = [] # Array<Tool>
var _guns : Array = [] # Array<Tool>

onready var LandingParticleScene = preload("res://scenes/vfx/BulletHitParticle.tscn")

var sync_data = {}


# ------------------------------------------------------------------------------
func set_max_speed(value : float) -> void:
	_max_speed = value
	
	
# ------------------------------------------------------------------------------
func set_time_to_max_speed(value : float) -> void:
	_time_to_max_speed = value
	_acceleration = _max_speed / value
	
	
# ------------------------------------------------------------------------------
func set_time_to_full_stop(value : float) -> void:
	_time_to_full_stop = value
	_deceleration = _max_speed / value


# ------------------------------------------------------------------------------
func set_jump_height(value : float) -> void:
	_jump_height = value
	calculate_vertical_motion_vars()
	
	
# ------------------------------------------------------------------------------
func set_time_to_jump_peak(value : float) -> void:
	_time_to_jump_peak = value
	calculate_vertical_motion_vars()
	
	
# ------------------------------------------------------------------------------
func calculate_vertical_motion_vars():
	# 2h/t
	_jump_speed = (-2.0 * _jump_height) / _time_to_jump_peak
	
	# -2h/t^2
	_gravity_acceleration = (
		2.0 * _jump_height) / (_time_to_jump_peak * _time_to_jump_peak)


# -----------------------------------------------------------------------------
func get_target() -> Vector2:
	return _target
	

# -----------------------------------------------------------------------------
func set_target(pos : Vector2) -> void:
	_target = pos


# -----------------------------------------------------------------------------
func get_velocity() -> Vector2:
	return velocity


# -----------------------------------------------------------------------------
func get_direction() -> float:
	return direction


# -----------------------------------------------------------------------------
func equip(new_tool : Tool) -> void:
	equipped.append(new_tool)
	new_tool.set_holder(self)
	
	if Tool.Type.DRILL == new_tool.tool_type:
		_drills.append(new_tool)
		
	elif Tool.Type.GUN == new_tool.tool_type:
		_guns.append(new_tool)


# -----------------------------------------------------------------------------
func mine() -> void:
	for drill in _drills:
		drill.activate()


# -----------------------------------------------------------------------------
func attack() -> void:
	for gun in _guns:
		gun.activate()
		

# -----------------------------------------------------------------------------
func get_drill_count() -> int:
	return _drills.size()


# -----------------------------------------------------------------------------
func get_gun_count() -> int:
	return _guns.size()


# -----------------------------------------------------------------------------
func get_health() -> float:
	return health


# -----------------------------------------------------------------------------
func _ready():
	calculate_vertical_motion_vars()
	set_time_to_max_speed(_time_to_max_speed)
	set_time_to_full_stop(_time_to_full_stop)


# -----------------------------------------------------------------------------
func _process(delta):
	# Don't process if in the editor.
	if Engine.editor_hint:
		return
	
	# Don't process if online and not the network master, is updated instead.
	if Network.is_online and not is_network_master():
		return
		
	_handle_item_vacuuming(delta)
	
	_handle_vertical_movement(delta)
	_handle_horizontal_movement(delta)
	_handle_sprite_flip()
	
	emit_signal("new_velocity", velocity)
	
	velocity = move_and_slide(velocity, Vector2.UP)
	_handle_network_syncing()


# -----------------------------------------------------------------------------
func _handle_vertical_movement(delta):
	
	# Checks for landing.
	var on_floor = is_on_floor()
	if not was_on_floor and on_floor:
		_create_landing_particles()
	was_on_floor = on_floor
	
	# Add the gravity acceleration to velocity.
	velocity.y += _gravity_acceleration * delta


# -----------------------------------------------------------------------------
func jump(delta):
	# Adds the jump speed to velocity if on the ground.
	if is_on_floor(): velocity.y = _jump_speed
	
	# If not on the ground, begin flying.
	else: thrust_jetpack(delta)


# -----------------------------------------------------------------------------
func thrust_jetpack(delta):
	$Jetpack.activate(delta)


# -----------------------------------------------------------------------------
func _handle_horizontal_movement(delta):
	
	# Applies deceleration if no movement input.
	if direction == 0.0:
		velocity.x -= min(_deceleration * delta, abs(velocity.x)) * sign(velocity.x)
	
	# Else applies acceleration in the movement direction.
	else:
		velocity.x += _acceleration * direction * delta
	
	# Clamps the horizontal movement to the max speed.
	if abs(velocity.x) > _max_speed:
		velocity.x = _max_speed * sign(velocity.x)


# -----------------------------------------------------------------------------
func _handle_sprite_flip():
	var dir_to_target = _target.x - global_position.x
	$AnimatedSprite.flip_h = dir_to_target < 0.0


# -----------------------------------------------------------------------------
func _handle_network_syncing():
	if Network.is_online:
		sync_data = {
			position = position,
			flip_h = $AnimatedSprite.flip_h,
		}
		
		emit_signal("sync_began", sync_data)
		rpc_unreliable("set_puppet_state", sync_data)


# -----------------------------------------------------------------------------
func accelerate(acceleration : Vector2):
	velocity += acceleration
	

# -----------------------------------------------------------------------------
puppet func set_puppet_state(state):
	position = state.position
	$AnimatedSprite.flip_h = state.flip_h
	emit_signal("sync_data_recieved", state)
	
	
# -----------------------------------------------------------------------------
func take_damage(damage, source = null):
	health -= damage
	
	emit_signal("damage_taken", health, source)
	
	if health <= 0:
		die()


# -----------------------------------------------------------------------------
func die():
	respawning = true
	
	set_process(false)
	set_physics_process(false)
	hide()
	
	var gems = inventory.count_and_remove_gems()
	
	var terrains = get_tree().get_nodes_in_group("terrain")
	if terrains and not terrains.empty():
		var terrain = terrains.front()
		
		if (terrain.has_method("spawn_crystals")):
			terrain.spawn_crystals(position, gems)
		else:
			print_debug("ERROR: Terrain does not have a 'spawn_crystals' method.")
			
	emit_signal("crystal_amount_changed", 0)
	emit_signal("died")
	

# -----------------------------------------------------------------------------
func pickup_crystal():
	if not respawning:
		var remainder = inventory.add_stack({ 
			type = ItemData.ItemType.GEM,
			quantity = 1,
		})
		if remainder == null:
			emit_signal("crystal_amount_changed", inventory.get_gem_count())
			return true
	return false


# -----------------------------------------------------------------------------
func respawn_complete():
	respawning = false
	
	set_process(true)
	set_physics_process(true)
	show()
	
	emit_signal("respawn_complete")


# -----------------------------------------------------------------------------
func _create_landing_particles():
	var containers = get_tree().get_nodes_in_group("particle_container")
	if containers and not containers.empty():
		var container = containers[0]
		var particle = LandingParticleScene.instance()
		container.add_child(particle)
		particle.position = $Feet.global_position
		var impact_direction = Vector3.DOWN
		particle.process_material.direction = impact_direction


# -----------------------------------------------------------------------------
func _handle_item_vacuuming(delta):
	var radius = $ItemVacuum/CollisionShape2D.shape.radius
	var one_over_radius_sq = 1.0 / (radius * radius)
	
	for item in _vacuumed_items:
		var dist = global_position - item.global_position
		var strength = 1.0 - (dist.length_squared() * one_over_radius_sq)
		var speed = (strength * _item_vacuum_speed)
		item.accelerate(dist * (speed * speed) * delta)


# -----------------------------------------------------------------------------
func _on_ItemVacuum_body_entered(body):
	if not _vacuumed_items.has(body):
		_vacuumed_items.append(body)


# -----------------------------------------------------------------------------
func _on_ItemVacuum_body_exited(body):
	if _vacuumed_items.has(body):
		_vacuumed_items.erase(body)


# -----------------------------------------------------------------------------
