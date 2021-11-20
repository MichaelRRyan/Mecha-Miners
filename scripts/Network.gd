extends Node

const FIRST_LOCAL_PLAYER_NUMBER = 0


var network = NetworkedMultiplayerENet.new()
var port = 1909
var max_players = 50


# -----------------------------------------------------------------------------

# =========================== HOST FUNCTIONALITY ============================

# -----------------------------------------------------------------------------
func start_server():
	network.create_server(port, max_players)
	get_tree().set_network_peer(network)
	print("Server Started")
	
	network.connect("peer_connected", self, "_peer_connected")
	network.connect("peer_disconnected", self, "_peer_disconnected")


# -----------------------------------------------------------------------------
func _peer_connected(peer_id):
	# TODO: Create player instance.
	
	print("Peer " + str(peer_id) + " Connected")


# -----------------------------------------------------------------------------
func _peer_disconnected(peer_id):
	# TODO: Remove player instance.
	
	print("Peer " + str(peer_id) + " Disconnected")


# -----------------------------------------------------------------------------

# =========================== CLIENT FUNCTIONALITY ============================

# -----------------------------------------------------------------------------
func connect_to_server(ip : String):
	network.create_client(ip, port)
	get_tree().set_network_peer(network)
	
	network.connect("connection_succeeded", self, "_on_connection_succeeded")
	network.connect("connection_failed", self, "_on_connection_failed")


# -----------------------------------------------------------------------------
func _on_connection_succeeded():
	print("Succesfully Connected")


# -----------------------------------------------------------------------------
func _on_connection_failed():
	print("Failed to Connect")
