extends "res://scripts/ai/AIController.gd"

# The maximum downward velocity before the bot will try to slow itself.
export(float) var max_velocity_y = 60.0


#-------------------------------------------------------------------------------
func _process(delta):
	# Slows itself if falling too fast.
	if subject.get_velocity().y > max_velocity_y:
		subject.thrust_jetpack(delta)
		
	# Else thrusts if too close to the ground.
	else:
		var raycast : RayCast2D = $GroundSensor
		raycast.force_raycast_update()
		if raycast.is_colliding():
			if raycast.get_collider().is_in_group("terrain"):
				subject.thrust_jetpack(delta)


#-------------------------------------------------------------------------------
