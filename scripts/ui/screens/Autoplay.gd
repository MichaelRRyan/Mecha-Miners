extends AnimationPlayer

export(String) var animation_name = ""


# ------------------------------------------------------------------------------
func _ready():
	play(animation_name)


# ------------------------------------------------------------------------------
