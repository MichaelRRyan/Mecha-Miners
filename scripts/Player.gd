extends KinematicBody2D

tool

signal died
signal crystal_amount_changed(total_crystals)

export var is_human : bool = false
export var health : float = 5.0

# -- Configurable Properties --
var max_speed = 50.0 # Pixels / Second
var time_to_max_speed = 0.1 # Seconds
var time_to_full_stop = 0.1 # Seconds
var jump_height = 32.0 # Pixels
var time_to_jump_peak = 0.6 # Seconds

# -- Auto Configured Properties --
var acceleration = 0.0
var deceleration = 0.0
var jump_speed = 0.0
var gravity_acceleration = 0.0
var velocity = Vector2.ZERO

# -- Private Variables --
var animation_id = 0
var respawning = false
var was_on_floor = false
var _target = Vector2.ZERO

var inventory = Inventory.new()

onready var LandingParticleScene = preload("res://scenes/BulletHitParticle.tscn")


enum AnimationName {
	Idle = 0,
	Jump = 1,
	Walk = 2,
	WalkReversed = 3,
}

var animation_names = [
	"idle",
	"jump",
	"walk",
	"walk_reversed",
]

# -- Param Map --
var params = {
	"horizontal_movement/max_speed": max_speed,
	"horizontal_movement/time_to_max_speed": time_to_max_speed,
	"horizontal_movement/time_to_full_stop": time_to_full_stop,
	"vertical_movement/jump_height": jump_height,
	"vertical_movement/time_to_jump_peak": time_to_jump_peak,
}


# -- Handle Public Properties --
# -----------------------------------------------------------------------------
func _set(property, value):
	if params.has(property):
		params[property] = value
		
		if property == "horizontal_movement/time_to_max_speed":
			acceleration = max_speed / value
		
		elif property == "horizontal_movement/time_to_full_stop":
			deceleration = max_speed / value
		
		elif (property == "vertical_movement/jump_height" or
			  property == "vertical_movement/time_to_jump_peak"):
				
			# 2h/t
			jump_speed = (-2.0 * jump_height) / time_to_jump_peak
			
			# -2h/t^2
			gravity_acceleration = (
				2.0 * jump_height) / (time_to_jump_peak * time_to_jump_peak)
		
		return true


# -----------------------------------------------------------------------------
func _get(property):
	if params.has(property):
		return params[property]


# -----------------------------------------------------------------------------
func _get_property_list():
	return [
		{ name = "horizontal_movement/max_speed", type = TYPE_REAL },
		{ name = "horizontal_movement/time_to_max_speed", type = TYPE_REAL },
		{ name = "horizontal_movement/time_to_full_stop", type = TYPE_REAL },
		{ name = "vertical_movement/jump_height", type = TYPE_REAL },
		{ name = "vertical_movement/time_to_jump_peak", type = TYPE_REAL },
	]
	

# -----------------------------------------------------------------------------
func _physics_process(delta):
	# Don't process if in the editor.
	if Engine.editor_hint:
		return
	
	# Don't process if online and not the network master, is updated instead.
	if Network.is_online and not is_network_master():
		return
		
	__handle_vertical_movement(delta)
	__handle_horizontal_movement(delta)
	__handle_sprite_flip()
	velocity = move_and_slide(velocity, Vector2.UP)
	__handle_network_syncing()


# -----------------------------------------------------------------------------
func __handle_vertical_movement(delta):
	
	# Checks for landing.
	var on_floor = is_on_floor()
	if not was_on_floor and on_floor:
		__create_landing_particles()
	was_on_floor = on_floor
	
	# Add the gravity acceleration to velocity.
	velocity.y += gravity_acceleration * delta
	
	if is_human:
		# If the jump input was just pressed.
		if Input.is_action_just_pressed("jump"):
			_jump(delta)
			
		# If already flying and the jump button is down, keep flying.
		elif Input.is_action_pressed("jump") and $Jetpack.is_flying():
			_thrust_jetpack(delta)


# -----------------------------------------------------------------------------
func _jump(delta):
	# Adds the jump speed to velocity if on the ground.
	if is_on_floor(): velocity.y = jump_speed
	
	# If not on the ground, begin flying.
	else: _thrust_jetpack(delta)


# -----------------------------------------------------------------------------
func _thrust_jetpack(delta):
	$Jetpack.activate(delta)


# -----------------------------------------------------------------------------
func __handle_horizontal_movement(delta):
	
	# Get the horizontal input.
	var direction = 0
	
	if is_human:
		direction = (Input.get_action_strength("move_right") - 
					 Input.get_action_strength("move_left"))
	
	# If there's no input.
	if direction == 0.0:
		# Applies deceleration.
		velocity.x -= min(deceleration * delta, abs(velocity.x)) * sign(velocity.x)
		
		# Play the appropriate no movement animation.
		if is_on_floor():
			__set_animation(AnimationName.Idle)
		else:
			__set_animation(AnimationName.Jump)	
	
	# If there is input.
	else:
		# Applies acceleration in the movement direction.
		velocity.x += acceleration * direction * delta
		
		# Play the appropriate movement animation.
		if is_on_floor():
			var dir_to_mouse = _target.x - global_position.x
			var reversed = sign(dir_to_mouse) != sign(direction)
			
			if reversed:
				__set_animation(AnimationName.WalkReversed)
			else:
				__set_animation(AnimationName.Walk)
		else:
			__set_animation(AnimationName.Jump)
	
	# Clamps the horizontal movement to the max speed.
	if abs(velocity.x) > max_speed:
		velocity.x = max_speed * sign(velocity.x)


# -----------------------------------------------------------------------------
func __handle_sprite_flip():
	var dir_to_mouse = get_global_mouse_position().x - global_position.x
	$AnimatedSprite.flip_h = dir_to_mouse < 0.0


# -----------------------------------------------------------------------------
func __handle_network_syncing():
	if Network.is_online: rpc_unreliable("set_puppet_state", {
		position = position,
		flip_h = $AnimatedSprite.flip_h,
		animation_id = animation_id,
		arms_data = $Arms.get_sync_data(),
	})


# -----------------------------------------------------------------------------
func __set_animation(id):
	animation_id = id
	$AnimatedSprite.play(animation_names[id])


# -----------------------------------------------------------------------------
func accelerate(_acceleration : Vector2):
	velocity += _acceleration
	

# -----------------------------------------------------------------------------
puppet func set_puppet_state(state):
	position = state.position
	$AnimatedSprite.flip_h = state.flip_h
	__set_animation(state.animation_id)
	$Arms.apply_sync_date(state.arms_data)
	
	
# -----------------------------------------------------------------------------
func take_damage(damage):
	health -= damage
	
	if health <= 0:
		die()


# -----------------------------------------------------------------------------
func die():
	respawning = true
	
	set_process(false)
	set_physics_process(false)
	hide()
	
	$Arms.set_process(false)
	
	var gems = inventory.count_and_remove_gems()
	
	var terrains = get_tree().get_nodes_in_group("terrain")
	if terrains and not terrains.empty():
		
		var terrain = terrains[0]
		
		if (terrain.has_method("spawn_crystals")):
			terrain.spawn_crystals(position, gems)
			
	emit_signal("crystal_amount_changed", 0)
	emit_signal("died")
	
	
# -----------------------------------------------------------------------------
func _input(event):
	
	if is_human and event is InputEventMouseMotion:
		_target = get_global_mouse_position()
	
#	if event is InputEventKey and event.scancode == KEY_K and event.is_pressed():
#		die()


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
	
	$Arms.set_process(true)


# -----------------------------------------------------------------------------
func __create_landing_particles():
	var containers = get_tree().get_nodes_in_group("particle_container")
	if containers and not containers.empty():
		var container = containers[0]
		var particle = LandingParticleScene.instance()
		container.add_child(particle)
		particle.position = $Feet.global_position
		var impact_direction = Vector3.DOWN
		particle.process_material.direction = impact_direction
		
		
# -----------------------------------------------------------------------------
