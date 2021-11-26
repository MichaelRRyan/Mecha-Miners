extends KinematicBody2D

tool

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

var animation_id = 0

enum AnimationName {
	Idle = 0,
	Jump = 1,
	Walk = 2,
	WalkReversed = 3
}

var animation_names = [
	"idle",
	"jump",
	"walk",
	"walk_reversed"
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
	
	# Move by the velocity.
	velocity = move_and_slide(velocity, Vector2.UP)
	
	__handle_interacton()
	__handle_network_syncing()


# -----------------------------------------------------------------------------
func __handle_vertical_movement(delta):
	
	# Add the gravity acceleration to velocity.
	velocity.y += gravity_acceleration * delta
	
	# If the jump input was just pressed.
	if Input.is_action_just_pressed("jump"):
		
		# Adds the jump speed to velocity if on the ground.
		if is_on_floor(): velocity.y = jump_speed
		
		# If not on the ground, begin flying.
		else: $Jetpack.activate(delta)
	
	# If already flying and the jump button is down, keep flying.
	elif Input.is_action_pressed("jump") and $Jetpack.is_flying():
		$Jetpack.activate(delta)
		

# -----------------------------------------------------------------------------
func __handle_horizontal_movement(delta):
	
	# Get the horizontal input.
	var direction = (Input.get_action_strength("move_right") - 
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
			var dir_to_mouse = get_global_mouse_position().x - global_position.x
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
func __handle_interacton():
	var direction_to_mouse = (get_global_mouse_position() - position).normalized()
	var angle = atan2(direction_to_mouse.y, direction_to_mouse.x)
	
	var flip = direction_to_mouse.x < 0.0
	var dir_sign = sign(direction_to_mouse.x)
	if dir_sign == 0: dir_sign = 1
	$Gun.scale.x = dir_sign
	$Gun.position.x = abs($Gun.position.x) * -dir_sign
	$Gun.rotation = angle - (deg2rad(180.0) if flip else 0.0)
	
	if Input.is_action_pressed("shoot"):
		$Gun.shoot()


# -----------------------------------------------------------------------------
func __handle_network_syncing():
	if Network.is_online: rpc_unreliable("set_puppet_state", {
		position = position,
		flip_h = $AnimatedSprite.flip_h,
		animation_id = animation_id,
		gun_scale_x = $Gun.scale.x,
		gun_position_x = $Gun.position.x,
		gun_rotation = $Gun.rotation
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
	$Gun.scale.x = state.gun_scale_x
	$Gun.position.x = state.gun_position_x
	$Gun.rotation = state.gun_rotation
	
	
# -----------------------------------------------------------------------------
