extends Node

signal player_connected(peer_id)
signal player_disconnected(peer_id)
signal connection_succeeded
signal server_opened


const SERVER_ID = 1

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
var is_online = false # Stored as an alternative to state for quick checks.


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
		emit_signal("server_opened")
		print("Server Started")
		is_online = true


# -----------------------------------------------------------------------------
func close_connection():
	if state == State.Hosting or state == State.Connected:
		network.close_connection()
		state = State.Offline
		is_online = false
	

# -----------------------------------------------------------------------------
func _peer_connected(peer_id):
	# TODO: Create player instance.
	emit_signal("player_connected", peer_id)
	print("Peer " + str(peer_id) + " Connected")


# -----------------------------------------------------------------------------
func _peer_disconnected(peer_id):
	# TODO: Remove player instance.
	emit_signal("player_disconnected", peer_id)
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
	emit_signal("connection_succeeded")
	print("Succesfully Connected")
	is_online = true
	

# -----------------------------------------------------------------------------
func _on_connection_failed():
	state = State.Offline
	print("Failed to Connect")


# -----------------------------------------------------------------------------
