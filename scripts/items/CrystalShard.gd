extends "res://scripts/items/ItemObject.gd"

export var gravity = 200.0
export var friction_multiplier = 0.96

var velocity = Vector2.ZERO
var was_on_floor = false


#-------------------------------------------------------------------------------
func _ready():
	$ShadowSprite.hide()
	$PickupParticles.restart()
	

#-------------------------------------------------------------------------------
func _physics_process(delta):
	velocity.y += gravity * delta
	velocity = move_and_slide(velocity, Vector2.UP)
	velocity.x *= friction_multiplier
	__check_for_floor()
	

#-------------------------------------------------------------------------------
func __check_for_floor():
	if $DestroyTimer.is_stopped():
		var on_floor = is_on_floor()
		
		# If the on_floor state has changed since last check.
		if was_on_floor != on_floor:
			if not was_on_floor and on_floor:
				$Animator.play("bob")
				$ShadowSprite.show()
				
			elif was_on_floor and not on_floor:
				$Animator.stop(true)
				$ShadowSprite.hide()
			
			was_on_floor = on_floor
	

#-------------------------------------------------------------------------------
func _on_Area2D_body_entered(body):
	if $DestroyTimer.is_stopped():
		if body.is_in_group("player"):
			if body.has_method("pickup_crystal"):
				if body.pickup_crystal():
					__on_picked_up()


#-------------------------------------------------------------------------------
func __on_picked_up():
	_on_picked_up() # From base class.
	
	if $Sprite.visible:
		$Sprite.hide()
		$ShadowSprite.hide()
		$PickupParticles.restart()
		$DestroyTimer.start()


#-------------------------------------------------------------------------------
func _on_DestroyTimer_timeout():
	queue_free()


#-------------------------------------------------------------------------------
