extends "res://scripts/ai/AIController.gd"

var _hover = true

#-------------------------------------------------------------------------------
func _ready():
	call_deferred("_equip_laser")
	

#-------------------------------------------------------------------------------
func _equip_laser():
	var laser = subject.find_node("MiningLaser")
	subject.equip(laser)


#-------------------------------------------------------------------------------
func _process(delta):
	# Else thrusts if too close to the ground.
	if _hover:
		var raycast : RayCast2D = $GroundSensor
		raycast.force_raycast_update()
		if raycast.is_colliding():
			if raycast.get_collider().is_in_group("terrain"):
				subject.thrust_jetpack(delta)


#-------------------------------------------------------------------------------
func set_hover(value : bool) -> void:
	_hover = value


#-------------------------------------------------------------------------------
