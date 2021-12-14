extends Node2D

func _ready():
	$Animator.play("bob")


func _on_Area2D_body_entered(body):
	if body.is_in_group("player"):
		if body.has_method("pickup_crystal"):
			body.pickup_crystal()
			__on_picked_up()


func __on_picked_up():
	$Sprite.hide()
	$ShadowSprite.hide()
	$PickupParticles.emitting = true
	$DestroyTimer.start()

func _on_DestroyTimer_timeout():
	queue_free()
