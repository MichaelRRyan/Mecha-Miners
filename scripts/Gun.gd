extends Sprite

export var cooldown = 0.15
export var automatic = false
var bullet_manager = null


# -----------------------------------------------------------------------------
func _ready():
	var managers = get_tree().get_nodes_in_group("bullet_manager")
	if managers and not managers.empty():
		bullet_manager = managers[0]
	

# -----------------------------------------------------------------------------
func _process(delta):
	
	var origin = global_position - position
	var direction_to_mouse = (get_global_mouse_position() - origin).normalized()
	var angle = atan2(direction_to_mouse.y, direction_to_mouse.x)
	
	var flip = direction_to_mouse.x < 0.0
	var dir_sign = sign(direction_to_mouse.x)
	if dir_sign == 0.0: dir_sign = 1
	scale.x = dir_sign
	position.x = abs(position.x) * -dir_sign
	rotation = angle - (deg2rad(180.0) if flip else 0.0)
	
	if (automatic and Input.is_action_pressed("shoot")
		or Input.is_action_just_pressed("shoot")):
			shoot()


# -----------------------------------------------------------------------------
func shoot():
	# If there's a reference to a bullet manager and cooldown has expired.
	if bullet_manager and $CooldownTimer.is_stopped():	
			
		bullet_manager.create_bullet(
			$Tip.global_position, 
			$Tip.global_rotation, 
			z_index - 1,
			global_position)
		
		$CooldownTimer.start(cooldown)


# -----------------------------------------------------------------------------
