extends Area2D

signal mineral_found(mineral_object)


func _on_ItemSensor_body_entered(body):
	if body.is_in_group("mineral"):
		emit_signal("mineral_found", body)
