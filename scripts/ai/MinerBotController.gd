extends "res://scripts/ai/AIController.gd"

#-------------------------------------------------------------------------------
func _process(delta):
	var raycast : RayCast2D = $GroundSensor
	raycast.force_raycast_update()
	if raycast.is_colliding():
		if raycast.get_collider().is_in_group("terrain"):
			subject.thrust_jetpack(delta)


#-------------------------------------------------------------------------------
