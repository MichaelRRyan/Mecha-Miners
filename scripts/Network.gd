extends Node

enum State {
	Offline,
	Connecting,
	Connected,
	Hosting
}

var state = State.Offline

var network = NetworkedMultiplayerENet.new()
var port = 1909
var max_players = 50


# -----------------------------------------------------------------------------
func _ready():
	network.connect("peer_connected", self, "_peer_connected")
	network.connect("peer_disconnected", self, "_peer_disconnected")
	network.connect("connection_succeeded", self, "_on_connection_succeeded")
	network.connect("connection_failed", self, "_on_connection_failed")
	

# -----------------------------------------------------------------------------

# =========================== HOST FUNCTIONALITY ============================

# -----------------------------------------------------------------------------
func start_server():
	if state == State.Offline:
		network.create_server(port, max_players)
		get_tree().set_network_peer(network)
		state = State.Hosting
		print("Server Started")


# -----------------------------------------------------------------------------
func close_connection():
	if state == State.Hosting or state == State.Connected:
		network.close_connection()
		state = State.Offline
	

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
	if state == State.Offline:
		network.create_client(ip, port)
		get_tree().set_network_peer(network)
		state = State.Connecting


# -----------------------------------------------------------------------------
func _on_connection_succeeded():
	state = State.Connected
	print("Succesfully Connected")


# -----------------------------------------------------------------------------
func _on_connection_failed():
	state = State.Offline
	print("Failed to Connect")


# -----------------------------------------------------------------------------
