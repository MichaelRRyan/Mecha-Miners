extends KinematicBody2D

signal menu_toggled

var player_in_range = false


# -----------------------------------------------------------------------------
func _on_PlayerDetector_body_entered(body):
	# Checks if the body is a non remote player.
	if (body.is_in_group("player") 
		and (not Network.is_online or body.is_network_master())):
			player_in_range = true


# -----------------------------------------------------------------------------
func _on_PlayerDetector_body_exited(body):
	# Checks if the body is a non remote player.
	if (body.is_in_group("player") 
		and (not Network.is_online or body.is_network_master())):
			player_in_range = false


# -----------------------------------------------------------------------------
func _input(event):
	if event.is_action_pressed("interact"):
		emit_signal("menu_toggled")

# -----------------------------------------------------------------------------
