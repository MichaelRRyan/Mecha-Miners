extends KinematicBody2D

export var movement_speed = 64.0
export var jump_speed = -160.0 # Negative so it's upwards.
export var gravity_acceleration = 256.0

var velocity = Vector2.ZERO


func _physics_process(delta):
	
	# Add the gravity acceleration to velocity.
	velocity.y += gravity_acceleration * delta
	
	# Add jump speed to velocity on jump input if on the ground.
	if Input.is_action_pressed("jump") and is_on_floor():
		velocity.y = jump_speed
	
	# Get the horizontal input.
	var hor_input = (Input.get_action_strength("move_right") - 
					 Input.get_action_strength("move_left"))
	
	# Set the horizontal velocity as the horizontal input times movement speed.
	velocity.x = hor_input * movement_speed
	
	# Move by the velocity.
	velocity = move_and_slide(velocity, Vector2.UP)
