extends KinematicBody2D

export var speed = 250.0
export var max_distance = 200.0

var velocity = Vector2.ZERO
var start_position = Vector2.ZERO


func _ready():
	velocity = Vector2(cos(rotation), sin(rotation)) * speed
	start_position = position


func _physics_process(delta):
	var _result = move_and_slide(velocity)
	
	if get_slide_count() > 0:
		queue_free()

	if (start_position - position).length_squared() > max_distance * max_distance:
		queue_free()
