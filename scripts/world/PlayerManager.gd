extends Node2D

onready var PlayerScene = preload("res://scenes/entities/Player.tscn")
onready var FollowPointScene = preload("res://scenes/entities/FollowPoint.tscn")
onready var BattleMinerBotScene = preload("res://scenes/entities/BattleMinerBot.tscn")
onready var MinerBotScene = preload("res://scenes/entities/MinerBot.tscn")
onready var DropPodScene = preload("res://scenes/world/DropPod.tscn")

export var base_player_health : float = 5.0
export var drop_height : float = -2000.0
export var camera_buffer : float = 100.0
export var level_top : float = -100.0

var spawn_point : Vector2 = Vector2.ZERO
var players = {} # Peer id: player instance
var _entities = []
var _main_camera : Camera2D = null
var _focused_entity_id = 0

var _local_player = null
var _local_follow_point = null
var _local_drop_pod = null


# ------------------------------------------------------------------------------
func get_local_player():
	return _local_player


# ------------------------------------------------------------------------------
func _ready():
#	_entities = get_tree().get_nodes_in_group("entity")
#	for entity in _entities:
#		var _r = entity.connect("died", self, "_on_player_died", [entity])
	
	spawn_point = $SpawnPoint.position
	#local_player = $Player
	#local_player.position = spawn_point
	
	# Connects to the networking signals.
	var _r
	_r = Network.connect("player_connected", self, "_on_player_connected")
	_r = Network.connect("player_disconnected", self, "_on_player_disconnected")
	_r = Network.connect("connection_succeeded", self, "_on_connection_succeeded")
	_r = Network.connect("server_opened", self, "_on_server_opened")
	
	# Gets the main camera.
	var main_cameras = get_tree().get_nodes_in_group("main_camera")
	if main_cameras != null and not main_cameras.empty():
		_main_camera = main_cameras.front()
		_main_camera.limit_top = int(drop_height + camera_buffer)
	
	# If offline, spawn the first few entities.
	if Network.state == Network.State.Offline:
		_spawn_first_entities()
	
	
# ------------------------------------------------------------------------------
func _spawn_first_entities():
	
	# Spawns the player.
	_local_player = PlayerScene.instance()
	
	# Defines the world width and left/right buffer.
	var world_width = 150
	var buffer = 10
	
	# Spawns and positions the drop pod.
	_local_drop_pod = DropPodScene.instance()
	add_child(_local_drop_pod)
	_local_drop_pod.connect("player_exited", self, "_on_DropPod_player_exited")
	_local_drop_pod.connect("player_entered", self, "_on_DropPod_player_entered")
	
	var x = randi() % (world_width - buffer * 2) + buffer
	_local_drop_pod.position = Vector2(x * 16.0, drop_height)
	
	# Spawns the follow point and adds it to the drop pod.
	_local_follow_point = FollowPointScene.instance()
	add_child(_local_follow_point)
	
	_local_follow_point.set_target(_local_drop_pod)
	
	_local_drop_pod.player = _local_player
	_local_drop_pod.follow_point = _local_follow_point
	_local_player.drop_pod = _local_drop_pod
	
	# Adds the camera to the drop pod's follow point.
	remove_child(_main_camera)
	_local_follow_point.add_child(_main_camera)
	_main_camera.position = Vector2.ZERO
	
	# TODO: Spawn the bots.
	var num_bots = randi() % 5 + 1
	for i in num_bots:
		pass
	
	
# ------------------------------------------------------------------------------
func _on_player_connected(peer_id):
	create_player(peer_id)
	

# ------------------------------------------------------------------------------
func _on_player_disconnected(peer_id):
	var player = get_node(str(peer_id))
	if player: player.queue_free()


# ------------------------------------------------------------------------------
func _on_connection_succeeded():
	_local_player.position = spawn_point
	setup_player_for_network()


# ------------------------------------------------------------------------------
func _on_server_opened():
	setup_player_for_network()


# ------------------------------------------------------------------------------
func setup_player_for_network():
	var player = get_node("Player")
	if player:
		var id = get_tree().get_network_unique_id()
		player.set_name(str(id))
		player.set_network_master(id)
		players[id] = player
	
	
# ------------------------------------------------------------------------------
func create_player(peer_id):
	var player = PlayerScene.instance()
	player.set_name(str(peer_id))
	player.set_network_master(peer_id)
	players[peer_id] = player
	var _r = player.connect("died", self, "_on_player_died", [player])
	add_child(player)


# ------------------------------------------------------------------------------
func _on_player_died(player : Node2D):
	player.position = spawn_point
	player.health = base_player_health
	
	var respawn_timer = Timer.new()
	add_child(respawn_timer)
	respawn_timer.connect("timeout", self, "_on_respawn_timer_timout", 
		[player, respawn_timer])
	respawn_timer.start(3.0)


# ------------------------------------------------------------------------------
func _on_respawn_timer_timout(player : Node2D, respawn_timer : Timer):
	player.respawn_complete()
	respawn_timer.queue_free()


# ------------------------------------------------------------------------------
func get_player_by_peer_id(peer_id):
	return players[peer_id]
	

# ------------------------------------------------------------------------------
func get_entity_by_rid(rid):
	var matching_entity = null
	
	for entity in _entities:
		if entity.get_rid() == rid:
			matching_entity = entity
			break
			
	return matching_entity


#-------------------------------------------------------------------------------
func _input(event):
	if Utility.is_debug_mode():
		if event.is_action_pressed("ai_perspective"):
			
			# If the main camera exists.
			if _main_camera != null:
				
				# If the camera is following a node.
				var camera_focus : Node = _main_camera.get_parent()
				if camera_focus != null:
					
					camera_focus.remove_child(_main_camera)
					_focused_entity_id = (_focused_entity_id + 1) % _entities.size()
					var next_entity = _entities[_focused_entity_id]
					
					if next_entity != null:
						next_entity.add_child(_main_camera)
						_main_camera.position = Vector2.ZERO
						

#-------------------------------------------------------------------------------
func _on_DropPod_player_exited(player):
	add_child(player)


#-------------------------------------------------------------------------------
func _on_DropPod_player_entered(player):
	remove_child(player)
	
	
#-------------------------------------------------------------------------------
