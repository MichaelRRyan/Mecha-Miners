extends Control


# ------------------------------------------------------------------------------
func _on_LoginButton_pressed():
	if get_tree().change_scene("res://scenes/world/World.tscn") != OK:
		print_debug("Cannot change scene to World.")


# ------------------------------------------------------------------------------
