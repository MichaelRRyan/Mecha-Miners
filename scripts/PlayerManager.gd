extends Node2D

onready var PlayerScene = preload("res://scenes/Player.tscn")

export var base_player_health : float = 5.0

var spawn_point : Vector2 = Vector2.ZERO
var players = {} # Peer id: player instance
var local_player


# -----------------------------------------------------------------------------
func get_local_player():
	return local_player


# -----------------------------------------------------------------------------
func _ready():
	local_player = $Player
	spawn_point = $SpawnPoint.position
	
	local_player.position = spawn_point
	var _r = local_player.connect("died", self, "_on_player_died", [local_player])
	
	_r = Network.connect("player_connected", self, "_on_player_connected")
	_r = Network.connect("player_disconnected", self, "_on_player_disconnected")
	_r = Network.connect("connection_succeeded", self, "_on_connection_succeeded")
	_r = Network.connect("server_opened", self, "_on_server_opened")
	

# -----------------------------------------------------------------------------
func _on_player_connected(peer_id):
	create_player(peer_id)
	

# -----------------------------------------------------------------------------
func _on_player_disconnected(peer_id):
	var player = get_node(str(peer_id))
	if player: player.queue_free()


# -----------------------------------------------------------------------------
func _on_connection_succeeded():
	local_player.position = spawn_point
	setup_player_for_network()


# -----------------------------------------------------------------------------
func _on_server_opened():
	setup_player_for_network()


# -----------------------------------------------------------------------------
func setup_player_for_network():
	var player = get_node("Player")
	if player:
		var id = get_tree().get_network_unique_id()
		player.set_name(str(id))
		player.set_network_master(id)
		players[id] = player
	
	
# -----------------------------------------------------------------------------
func create_player(peer_id):
	var player = PlayerScene.instance()
	player.set_name(str(peer_id))
	player.set_network_master(peer_id)
	players[peer_id] = player
	var _r = player.connect("died", self, "_on_player_died", [player])
	add_child(player)


# -----------------------------------------------------------------------------
func _on_player_died(player : Node2D):
	player.position = spawn_point
	player.health = base_player_health
	
	var respawn_timer = Timer.new()
	add_child(respawn_timer)
	respawn_timer.connect("timeout", self, "_on_respawn_timer_timout", 
		[player, respawn_timer])
	respawn_timer.start(3.0)


# -----------------------------------------------------------------------------
func _on_respawn_timer_timout(player : Node2D, respawn_timer : Timer):
	player.respawn_complete()
	respawn_timer.queue_free()


# -----------------------------------------------------------------------------
func get_player_by_peer_id(peer_id):
	return players[peer_id]


# -----------------------------------------------------------------------------
