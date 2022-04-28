extends Node

signal player_connected(peer_id)
signal player_disconnected(peer_id)
signal connection_succeeded
signal connection_failed
signal server_opened

signal create_identity_response(identity_id)

const IS_SERVER = false
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
var setup_players = []

# _player_data = { 
#	 [peer_id]: {
# 		 "user_id": [user_id],
#		 "identity_id": [identity_id],
# 	 },
# }
var _player_data : Dictionary = {}

# _create_identity_queue = [ 
#	 { 
#		 "peer_id": [ peer_id ], 
#		 "identity_id": [ identity_id ], 
#		 "eth_address": [ eth_address ],
#	 },
# ]
var _create_identity_queue : Array = []


# ------------------------------------------------------------------------------
func is_client() -> bool:
	return Network.State.Connected == Network.state


# ------------------------------------------------------------------------------
func is_host() -> bool:
	return Network.State.Hosting == Network.state
	
	
# ------------------------------------------------------------------------------
func _ready():
	network.connect("peer_connected", self, "_peer_connected")
	network.connect("peer_disconnected", self, "_peer_disconnected")
	network.connect("connection_succeeded", self, "_on_connection_succeeded")
	network.connect("connection_failed", self, "_on_connection_failed")
	
	if IS_SERVER:
		_setup_server()
		
	
# ------------------------------------------------------------------------------
func _setup_server():
	start_server()
	
	# Loads the secret file.
	var file = File.new()
	file.open("res://secret.json", File.READ)
	var json = JSON.parse(file.get_as_text())
	
	# Checks the parse was successful.
	if json.error == OK:
		
		# Logs in with the secret.
		var secret = json.result
		Enjin.request_app_access_token(secret.app_id, secret.secret)
		
		var _r = Enjin.connect("create_identity_response", self, "_on_Enjin_create_identity_response")
		if get_tree().change_scene("res://scenes/world/World.tscn") != OK:
			print_debug("Unable to switch scene to World.")
		
	else:
		print_debug("Error loading secret.json")


# ------------------------------------------------------------------------------

# =========================== HOST FUNCTIONALITY ===============================

# ------------------------------------------------------------------------------
func start_server():
	if state == State.Offline:
		network.create_server(port, max_players)
		get_tree().set_network_peer(network)
		state = State.Hosting
		emit_signal("server_opened")
		print("Server Started")
		is_online = true


# ------------------------------------------------------------------------------
func close_connection():
	if state == State.Hosting or state == State.Connected:
		network.close_connection()
		state = State.Offline
		is_online = false


# ------------------------------------------------------------------------------
remote func identity_requested(user_id : int, eth_address : String) -> void:
	var peer_id = get_tree().get_rpc_sender_id()
	
	# Creates the identity if there's nothing on the queue.
	if _create_identity_queue.empty():
		Enjin.create_identity(user_id, eth_address)	
	
	# Adds the data to the queue.
	_create_identity_queue.append({
		"peer_id": peer_id,
		"user_id": user_id,
		"eth_address": eth_address,
	})


# ------------------------------------------------------------------------------
remote func login_registered(user_id : int, identity_id : int) -> void:
	var peer_id = get_tree().get_rpc_sender_id()
	_player_data[peer_id]["user_id"] = user_id
	_player_data[peer_id]["identity_id"] = identity_id
	
	print("Peer " + str(peer_id) + " logged in as user " + str(user_id))


# ------------------------------------------------------------------------------
remote func mint_me_some_tokens(eth_address : String) -> void:
	var identity_id = Enjin.MECHA_MINERS_IDENTITY_ID
	Enjin.mint_tokens(identity_id, Enjin.APP_ID, Enjin.ELIXIRITE_ID, eth_address, 1)
		

# ------------------------------------------------------------------------------
func _on_Enjin_create_identity_response(data, _errors) -> void:
	# Takes the peer id from the top element and pops it.
	var peer_id = _create_identity_queue.pop_front().peer_id
	
	# Returns the appropriate response.
	if data != null:
		rpc_id(peer_id, "create_identity_response", data)
	else:
		rpc_id(peer_id, "create_identity_response", null)
	
	# If the queue has more items, create the next identity.
	if not _create_identity_queue.empty():
		var item = _create_identity_queue.front()
		Enjin.create_identity(item.user_id, item.eth_address)	


# ------------------------------------------------------------------------------
func _peer_connected(peer_id):
	# TODO: Create player instance.
	_player_data[peer_id] = {}
	emit_signal("player_connected", peer_id)
	print("Peer " + str(peer_id) + " Connected")


# ------------------------------------------------------------------------------
func _peer_disconnected(peer_id):
	# TODO: Remove player instance.
	var _r = _player_data.erase(peer_id)
	emit_signal("player_disconnected", peer_id)
	print("Peer " + str(peer_id) + " Disconnected")
	
	if setup_players.has(peer_id):
		setup_players.erase(peer_id)


# ------------------------------------------------------------------------------

# =========================== CLIENT FUNCTIONALITY =============================

# ------------------------------------------------------------------------------
func connect_to_server():
	if state == State.Offline:
		network.create_client(UserPreferences.get_default_ip(), port)
		get_tree().set_network_peer(network)
		state = State.Connecting


# ------------------------------------------------------------------------------
func request_identity(user_id : int, eth_address : String) -> void:
	if state == State.Connected:
		rpc_id(SERVER_ID, "identity_requested", user_id, eth_address)
	else:
		print_debug("Error: Not connected to a server.")
	
	
# ------------------------------------------------------------------------------
remote func create_identity_response(identity) -> void:
	if get_tree().get_rpc_sender_id() == SERVER_ID:
		emit_signal("create_identity_response", identity)


# ------------------------------------------------------------------------------
func notify_of_login(user_id, identity_id):
	if state == State.Connected:
		rpc_id(SERVER_ID, "login_registered", user_id, identity_id)
	else:
		print_debug("Error: Not connected to a server.")


# ------------------------------------------------------------------------------
func mint_tokens(eth_address : String) -> void:
	if state == State.Connected:
		rpc_id(SERVER_ID, "mint_me_some_tokens", eth_address)
	else:
		print_debug("Error: Not connected to a server.")


# ------------------------------------------------------------------------------
func _on_connection_succeeded():
	state = State.Connected
	emit_signal("connection_succeeded")
	print("Succesfully Connected")
	is_online = true
	

# ------------------------------------------------------------------------------
func _on_connection_failed():
	state = State.Offline
	emit_signal("connection_failed")
	print("Failed to Connect")


# ------------------------------------------------------------------------------
