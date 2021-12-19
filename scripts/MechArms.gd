extends Node2D

onready var equiped1 = $Gun1
onready var equiped2 = $Gun2
onready var front_position = $Gun1.position.x
onready var back_position = $Gun2.position.x


# -----------------------------------------------------------------------------
func _ready():
	var parent = get_parent()
	if parent:
		var rid = parent.get_rid()
		equiped1.holder_rid = rid
		equiped2.holder_rid = rid


# -----------------------------------------------------------------------------
func _process(_delta):
	
	# Don't process if online and not the network master, is updated instead.
	if Network.is_online and not is_network_master():
		return
	
	var direction_to_mouse = (get_global_mouse_position() - global_position).normalized()
	
	var flip = direction_to_mouse.x < 0.0
	var dir_sign = sign(direction_to_mouse.x)
	if dir_sign == 0.0: dir_sign = 1
	
	scale.x = dir_sign

	if flip:
		equiped1.position.x = back_position
		equiped2.position.x = front_position
		equiped1.frame = 1
		equiped2.frame = 0

	else:
		equiped1.position.x = front_position
		equiped2.position.x = back_position
		equiped1.frame = 0
		equiped2.frame = 1
	
	equiped1.z_index = 2 * dir_sign
	equiped2.z_index = -2 * dir_sign
	
	# Works out the angle to the mouse sets the equipment's rotation to it.
	var angle = atan2(direction_to_mouse.y, direction_to_mouse.x)
	if flip: angle = deg2rad(180.0) - angle
	equiped1.rotation = angle
	equiped2.rotation = angle
	
	if (equiped1.automatic and Input.is_action_pressed("action1")
			or Input.is_action_just_pressed("action1")):
				equiped1.shoot()
	
	if (equiped2.automatic and Input.is_action_pressed("action2")
			or Input.is_action_just_pressed("action2")):
				equiped2.shoot()


# -----------------------------------------------------------------------------
func get_sync_data():
	return {
		scale_x = scale.x,
		
		equiped1_position_x = equiped1.position.x,
		equiped1_rotation = equiped1.rotation,
		equiped1_z_index = equiped1.z_index,
		equiped1_frame = equiped1.frame,
		
		equiped2_position_x = equiped2.position.x,
		equiped2_rotation = equiped2.rotation,
		equiped2_z_index = equiped2.z_index,
		equiped2_frame = equiped2.frame,
	}


# -----------------------------------------------------------------------------
func apply_sync_date(data):
	scale.x = data.scale_x
	
	equiped1.position.x = data.equiped1_position_x
	equiped1.rotation =	data.equiped1_rotation
	equiped1.z_index = data.equiped1_z_index
	equiped1.frame = data.equiped1_frame
	
	equiped2.position.x = data.equiped2_position_x
	equiped2.rotation =	data.equiped2_rotation
	equiped2.z_index = data.equiped2_z_index
	equiped2.frame = data.equiped2_frame


# -----------------------------------------------------------------------------
