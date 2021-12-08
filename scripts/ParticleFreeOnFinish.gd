extends Particles2D

tool


func _ready():
	if not Engine.editor_hint:
		emitting = true
		$FreeTimer.start(lifetime)


func _on_FreeTimer_timeout():
	queue_free()
