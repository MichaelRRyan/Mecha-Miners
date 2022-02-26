extends "res://scripts/equipment/Tool.gd"

export var cooldown = 0.25
var bullet_manager = null
var _holder_rid = null


# -----------------------------------------------------------------------------
# An override of the Tool base class's set_holder method.
func set_holder(holder : Node2D):
	_holder = holder
	_holder_rid = _holder.get_rid()


# -----------------------------------------------------------------------------
# An override of the Tool base class's activate method.
func activate():
	# If there's a reference to a bullet manager and cooldown has expired.
	if bullet_manager and $CooldownTimer.is_stopped():	
			
		bullet_manager.create_bullet(
			$Tip.global_position, 
			$Tip.global_rotation, 
			z_index - 1,
			global_position,
			_holder_rid)
		
		$CooldownTimer.start(cooldown)


# -----------------------------------------------------------------------------
func _ready():
	var managers = get_tree().get_nodes_in_group("bullet_manager")
	if managers and not managers.empty():
		bullet_manager = managers[0]
		
		
# -----------------------------------------------------------------------------
