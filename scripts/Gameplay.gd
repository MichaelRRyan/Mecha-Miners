extends Node2D

onready var PlayerScene = preload("res://scenes/Player.tscn")


# -----------------------------------------------------------------------------
func _ready():
	Network.connect("player_connected", self, "_on_player_connected")
	Network.connect("player_disconnected", self, "_on_player_disconnected")
	Network.connect("connection_succeeded", self, "_on_connection_succeeded")
	Network.connect("server_opened", self, "_on_server_opened")


# -----------------------------------------------------------------------------
func _on_player_connected(peer_id):
	create_player(peer_id)
	

# -----------------------------------------------------------------------------
func _on_player_disconnected(peer_id):
	var player = $Players.get_node(str(peer_id))
	if player: player.queue_free()


# -----------------------------------------------------------------------------
func _on_connection_succeeded():
	setup_player_for_network()
	create_server_players()


# -----------------------------------------------------------------------------
func _on_server_opened():
	setup_player_for_network()


# -----------------------------------------------------------------------------
func setup_player_for_network():
	var player = $Players.get_node("Player")
	if player:
		var id = get_tree().get_network_unique_id()
		player.set_name(str(id))
		player.set_network_master(id)
		player.is_online = true


# -----------------------------------------------------------------------------
func create_server_players():
	var peer_ids = get_tree().get_network_connected_peers()
	for peer_id in peer_ids:
		create_player(peer_id)
	
	
# -----------------------------------------------------------------------------
func create_player(peer_id):
	var player = PlayerScene.instance()
	player.set_name(str(peer_id))
	player.set_network_master(peer_id)
	player.is_online = true
	$Players.add_child(player)


# -----------------------------------------------------------------------------
