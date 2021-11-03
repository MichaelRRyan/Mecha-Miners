extends KinematicBody2D

tool

export var jump_speed = -160.0 # Negative so it's upwards.
export var gravity_acceleration = 256.0

var max_speed = 50.0 # Pixels / Second
var time_to_max_speed = 0.1 # Seconds
var time_to_full_stop = 0.1 # Seconds

var acceleration = 0.0
var deceleration = 0.0
var velocity = Vector2.ZERO


# -- Param Map --
var params = {
	"horizontal_movement/max_speed": max_speed,
	"horizontal_movement/time_to_max_speed": time_to_max_speed,
	"horizontal_movement/time_to_full_stop": time_to_full_stop,
}

func _set(property, value):
	if params.has(property):
		params[property] = value
		
		if property == "horizontal_movement/time_to_max_speed":
			acceleration = max_speed / value
		
		elif property == "horizontal_movement/time_to_full_stop":
			deceleration = max_speed / value
		
		return true


func _get(property):
	if params.has(property):
		return params[property]


func _get_property_list():
	return [
		{ name = "horizontal_movement/max_speed", type = TYPE_REAL },
		{ name = "horizontal_movement/time_to_max_speed", type = TYPE_REAL },
		{ name = "horizontal_movement/time_to_full_stop", type = TYPE_REAL },
	]


func _ready():
	print(str(acceleration) + " " + str(deceleration))


func _physics_process(delta):
	if Engine.editor_hint:
		return
		
	# Add the gravity acceleration to velocity.
	velocity.y += gravity_acceleration * delta
	
	# Add jump speed to velocity on jump input if on the ground.
	if Input.is_action_pressed("jump") and is_on_floor():
		velocity.y = jump_speed
	
	# Get the horizontal input.
	var direction = (Input.get_action_strength("move_right") - 
					 Input.get_action_strength("move_left"))
	
	# If there's no input.
	if direction == 0.0:
		velocity.x -= min(deceleration * delta, abs(velocity.x)) * sign(velocity.x)
	
	# If there is input.
	else:
		velocity.x  += acceleration * direction * delta
	
	# Clamps the horizontal movement to the max speed.
	if abs(velocity.x) > max_speed:
		velocity.x = max_speed * sign(velocity.x)
	
	# Move by the velocity.
	velocity = move_and_slide(velocity, Vector2.UP)
