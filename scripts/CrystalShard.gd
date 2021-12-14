extends Node2D

func _ready():
	$Animator.play("bob")
	$PickupParticles.restart()


func _on_Area2D_body_entered(body):
	if body.is_in_group("player"):
		if body.has_method("pickup_crystal"):
			body.pickup_crystal()
			__on_picked_up()


func __on_picked_up():
	if $Sprite.visible:
		$Sprite.hide()
		$ShadowSprite.hide()
		$PickupParticles.restart()
		$DestroyTimer.start()

func _on_DestroyTimer_timeout():
	queue_free()
