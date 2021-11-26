extends Sprite

export var cooldown = 0.15
var bullet_manager = null


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
			z_index - 1)
		
		$CooldownTimer.start(cooldown)


# -----------------------------------------------------------------------------
