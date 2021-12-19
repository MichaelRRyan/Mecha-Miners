extends Sprite

export var cooldown = 0.25
export var automatic = false
var bullet_manager = null
var holder_rid = null


# -----------------------------------------------------------------------------
func _ready():
	var managers = get_tree().get_nodes_in_group("bullet_manager")
	if managers and not managers.empty():
		bullet_manager = managers[0]


# -----------------------------------------------------------------------------
func shoot():
	# If there's a reference to a bullet manager and cooldown has expired.
	if bullet_manager and $CooldownTimer.is_stopped():	
			
		bullet_manager.create_bullet(
			$Tip.global_position, 
			$Tip.global_rotation, 
			z_index - 1,
			global_position,
			holder_rid)
		
		$CooldownTimer.start(cooldown)


# -----------------------------------------------------------------------------
