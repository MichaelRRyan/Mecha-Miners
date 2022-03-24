extends Node2D

onready var equipped1 = $Equipped1
onready var equipped2 = $Equipped2
onready var front_position = $Equipped1.position.x
onready var back_position = $Equipped2.position.x

onready var _parent = get_parent()


# -----------------------------------------------------------------------------
func _ready():
	if _parent:
		equipped1.set_holder(_parent)
		equipped2.set_holder(_parent)
	else:
		set_process(false)


# -----------------------------------------------------------------------------
func _process(_delta):
	
	# Don't process if online and not the network master, is updated instead.
	if Network.is_online and not is_network_master():
		return
	
	var direction_to_target = (_parent._target - global_position).normalized()
	
	var flip = direction_to_target.x < 0.0
	var dir_sign = sign(direction_to_target.x)
	if dir_sign == 0.0: dir_sign = 1
	
	scale.x = dir_sign

	if flip:
		equipped1.position.x = back_position
		equipped2.position.x = front_position
		equipped1.frame = 1
		equipped2.frame = 0

	else:
		equipped1.position.x = front_position
		equipped2.position.x = back_position
		equipped1.frame = 0
		equipped2.frame = 1
	
	equipped1.z_index = 2 * dir_sign
	equipped2.z_index = -2 * dir_sign
	
	# Works out the angle to the mouse sets the equipment's rotation to it.
	var angle = atan2(direction_to_target.y, direction_to_target.x)
	if flip: angle = deg2rad(180.0) - angle
	equipped1.rotation = angle
	equipped2.rotation = angle
	
	if _parent.is_human:
		if (equipped1.automatic and Input.is_action_pressed("action1")
				or Input.is_action_just_pressed("action1")):
					equipped1.activate()
		
		if (equipped2.automatic and Input.is_action_pressed("action2")
				or Input.is_action_just_pressed("action2")):
					equipped2.activate()


# -----------------------------------------------------------------------------
func get_sync_data():
	return {
		scale_x = scale.x,
		
		equipped1_position_x = equipped1.position.x,
		equipped1_rotation = equipped1.rotation,
		equipped1_z_index = equipped1.z_index,
		equipped1_frame = equipped1.frame,
		
		equipped2_position_x = equipped2.position.x,
		equipped2_rotation = equipped2.rotation,
		equipped2_z_index = equipped2.z_index,
		equipped2_frame = equipped2.frame,
	}


# -----------------------------------------------------------------------------
func apply_sync_date(data):
	scale.x = data.scale_x
	
	equipped1.position.x = data.equipped1_position_x
	equipped1.rotation =	data.equipped1_rotation
	equipped1.z_index = data.equipped1_z_index
	equipped1.frame = data.equipped1_frame
	
	equipped2.position.x = data.equipped2_position_x
	equipped2.rotation =	data.equipped2_rotation
	equipped2.z_index = data.equipped2_z_index
	equipped2.frame = data.equipped2_frame


# -----------------------------------------------------------------------------
