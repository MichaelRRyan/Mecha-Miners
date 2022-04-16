extends AnimatedSprite


enum AnimationName {
	Idle = 0,
	Hurt = 1,
}

var animation_names = [
	"idle",
	"hurt",
]

var _animation_id = 0


# -----------------------------------------------------------------------------
func _on_MinerBot_sync_began(sync_data):
	sync_data["animation_id"] = _animation_id


# -----------------------------------------------------------------------------
func _on_MinerBot_sync_data_recieved(sync_data):
	_set_animation(sync_data.animation_id)


# ------------------------------------------------------------------------------
func _set_animation(id):
	_animation_id = id
	play(animation_names[id])


# -----------------------------------------------------------------------------
func _on_MinerBot_damage_taken(health):
	if health > 0.0:
		_set_animation(AnimationName.Hurt)
		yield(self, "animation_finished")
		_set_animation(AnimationName.Idle)


# -----------------------------------------------------------------------------
