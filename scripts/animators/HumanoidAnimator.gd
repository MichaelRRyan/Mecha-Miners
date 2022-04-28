extends AnimatedSprite

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

var subject : KinematicBody2D = null
var animation_id = 0


# ------------------------------------------------------------------------------
func _ready():
	var parent = get_parent()
	if (parent and parent is KinematicBody2D and 
		parent.has_method("get_direction") and parent.has_method("get_target")):
			subject = parent
	else:
		set_process(false)


# ------------------------------------------------------------------------------
func _process(_delta):
	var direction = subject.get_direction()
	if direction == 0.0:
		
		# Play the appropriate no movement animation.
		if subject.is_on_floor():
			_set_animation(AnimationName.Idle)
		else:
			_set_animation(AnimationName.Jump)	
	
	else:
		
		# Play the appropriate movement animation.
		if subject.is_on_floor():
			var dir_to_mouse = subject.get_target().x - subject.global_position.x
			var reversed = sign(dir_to_mouse) != sign(direction)
			
			if reversed:
				_set_animation(AnimationName.WalkReversed)
			else:
				_set_animation(AnimationName.Walk)
		else:
			_set_animation(AnimationName.Jump)
	

# ------------------------------------------------------------------------------
func _set_animation(id):
	animation_id = id
	play(animation_names[id])


# ------------------------------------------------------------------------------
func _on_Humanoid_sync_began(sync_data):
	sync_data["animation_id"] = animation_id


# ------------------------------------------------------------------------------
func _on_Humanoid_sync_data_recieved(sync_data):
	if sync_data.has("animation_id"):
		_set_animation(sync_data["animation_id"])


# ------------------------------------------------------------------------------
