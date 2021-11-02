extends KinematicBody2D

export var movement_speed = 64.0
export var jump_speed = -160.0 # Negative so it's upwards.
export var gravity_acceleration = 256.0

var velocity = Vector2.ZERO

func _process(delta):
	
	velocity.y += gravity_acceleration * delta
	
	if Input.is_action_pressed("jump") and is_on_floor():
		velocity.y = jump_speed
	
	var hor_input = (Input.get_action_strength("move_right") - 
					 Input.get_action_strength("move_left"))
	
	velocity.x = hor_input * movement_speed
	
	var _result = move_and_slide(velocity, Vector2.UP)
