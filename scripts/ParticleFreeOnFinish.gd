extends Particles2D

tool


func _ready():
	emitting = true
	$FreeTimer.start(lifetime)


func _on_FreeTimer_timeout():
	queue_free()
