extends Node2D

const WORLD_WIDTH = 150
const SPAWN_BUFFER = 10

enum EntityType {
	PLAYER = 0,
	MINER_BOT = 1,
	BATTLE_MINER_BOT = 2,
}

onready var EntityScenes = {
	EntityType.PLAYER: preload("res://scenes/entities/Player.tscn"),
	EntityType.MINER_BOT: preload("res://scenes/entities/MinerBot.tscn"),
	EntityType.BATTLE_MINER_BOT: preload("res://scenes/entities/BattleMinerBot.tscn"),
}

onready var FollowPointScene = preload("res://scenes/entities/FollowPoint.tscn")
onready var DropPodScene = preload("res://scenes/world/DropPod.tscn")

export var base_player_health : float = 5.0
export var drop_height : float = -2800.0
export var camera_buffer : float = 800.0
export var level_top : int = -100

var players = {} # Peer id: player instance
var _entities = []
var _entity_data = []
var _main_camera : Camera2D = null
var _focused_entity_id = 0

var _local_player = null
var _cam_follow_point = null

var _free_drop_positons = []

# ------------------------------------------------------------------------------
func get_local_player():
	return _local_player


# ------------------------------------------------------------------------------
func _ready():
	# Connects to the networking signal.
	var _r = Network.connect("player_disconnected", self, "_on_player_disconnected")
	
	# Gets the main camera.
	var main_cameras = get_tree().get_nodes_in_group("main_camera")
	if main_cameras != null and not main_cameras.empty():
		_main_camera = main_cameras.front()
		_main_camera.limit_top = int(drop_height + camera_buffer)
	
	# If offline or hosting, spawns the first few entities.
	var net_state = Network.state
	if Network.State.Offline == net_state or Network.State.Hosting == net_state:
		_spawn_first_entities()
		
	elif Network.State.Connected == net_state:
		rpc_id(Network.SERVER_ID, "_request_entity_data")
	

# ------------------------------------------------------------------------------
# SERVER METHOD.
remote func _request_entity_data():
	if Network.State.Hosting == Network.state:
		var peer_id = get_tree().get_rpc_sender_id()
		create_player(peer_id)
		rpc_id(peer_id, "_recieve_entity_data", _entity_data)
		
		
# ------------------------------------------------------------------------------
# CLIENT METHOD.
remote func _recieve_entity_data(entity_data : Array):
	var sender_id = get_tree().get_rpc_sender_id()
	if Network.SERVER_ID == sender_id:
		for data in entity_data:
			var local = data["peer_id"] == get_tree().get_network_unique_id()
			_spawn_entity_and_drop(data["type"], local, data["peer_id"], data["is_child"])
			
			if not local and not Network.setup_players.has(data["peer_id"]):
				Network.setup_players.append(data["peer_id"])
			
		rpc_id(Network.SERVER_ID, "_setup_complete")
		

# ------------------------------------------------------------------------------
# SERVER METHOD.
remote func _setup_complete():
	if Network.State.Hosting == Network.state:
		var peer_id = get_tree().get_rpc_sender_id()
		
		for id in Network.setup_players:
			rpc_id(id, "_player_ready", peer_id)
			
		Network.setup_players.append(peer_id)


# ------------------------------------------------------------------------------
# CLIENT METHOD.
remote func _player_ready(peer_id):
	var sender_id = get_tree().get_rpc_sender_id()
	if Network.SERVER_ID == sender_id:
		Network.setup_players.append(peer_id)
	
	
# ------------------------------------------------------------------------------
func _spawn_first_entities():
	
	for x in range(SPAWN_BUFFER, WORLD_WIDTH - SPAWN_BUFFER * 2):
		_free_drop_positons.append(x)
	
	if Network.State.Offline == Network.state:
		_spawn_entity_and_drop(EntityType.PLAYER, true)
	
	# Spawns 2 to 5 bots.
	var num_bots = randi() % 4 + 2
	for _i in num_bots:
		
		var type = (EntityType.MINER_BOT if randi() % 2 == 0 
			else EntityType.BATTLE_MINER_BOT)
			
		_spawn_entity_and_drop(type, true, Network.SERVER_ID)
	
	
# ------------------------------------------------------------------------------
func _spawn_entity_and_drop(entity_type, is_local, peer_id = -1, is_child = false):
	
	var entity = EntityScenes[entity_type].instance()
	var drop_pod = DropPodScene.instance()
	
	# Adds the drop pod as a child and connects its signals.
	add_child(drop_pod)
	
	if is_local:
		drop_pod.connect("player_exited", self, "_on_DropPod_player_exited")
		drop_pod.connect("player_entered", self, "_on_DropPod_player_entered")
		drop_pod.connect("landed", entity, "_on_DropPod_landed")
	
	# If offline or hosting, sets the position.
	var net_state = Network.state
	if Network.State.Offline == net_state or Network.State.Hosting == net_state:
		
		# Positions the drop pod in an empty spot.
		var x = _free_drop_positons[randi() % _free_drop_positons.size()]
		_mark_drop_pos_taken(x)
		drop_pod.position = Vector2(x * 16.0, drop_height)
	
	# Assigned the necessary references.
	drop_pod.player = entity
	entity.drop_pod = drop_pod
	drop_pod.max_height = drop_height
	
	var _r = entity.connect("died", self, "_on_player_died", [entity])
	
	if Network.State.Offline != Network.state:
		var entity_identifier = str(peer_id) + "_" + str(_entities.size())
		entity.set_name(str(entity_type) + "_" + entity_identifier)
		entity.set_network_master(peer_id)
		
		drop_pod.set_name("DropPod_" + entity_identifier)
		drop_pod.set_network_master(Network.SERVER_ID)
	
		if EntityType.PLAYER == entity_type:
			players[peer_id] = _local_player
	
	_entities.append(entity)
	
	if Network.State.Hosting == Network.state:
		_entity_data.append({
			"type": entity_type,
			"peer_id": peer_id,
			"is_child": false,
		})
	
	if EntityType.PLAYER == entity_type and is_local:
		_setup_local(entity, drop_pod)
	
	if is_child:
		add_child(entity)


# ------------------------------------------------------------------------------
# Checks the area around the position to ensure it's clear.
func _mark_drop_pos_taken(x_cell):
	var world_min = SPAWN_BUFFER
	var world_max = WORLD_WIDTH - SPAWN_BUFFER * 2
	
	for x in range(max(world_min, x_cell - 3), min(world_max, x_cell + 3)):
		if _free_drop_positons.has(x):
			_free_drop_positons.erase(x)
	

# ------------------------------------------------------------------------------
func _setup_local(player, drop_pod):
	_local_player = player
	
	# Spawns the follow point and adds it to the drop pod.
	_cam_follow_point = FollowPointScene.instance()
	add_child(_cam_follow_point)
	_cam_follow_point.set_target(drop_pod)
	drop_pod.follow_point = _cam_follow_point
	drop_pod.is_local = true
	
	# Adds the camera to the drop pod's follow point.
	remove_child(_main_camera)
	_cam_follow_point.add_child(_main_camera)
	_main_camera.position = Vector2.ZERO
	
	drop_pod.connect("landed", self, "_on_local_DropPod_landed")
	
	# Gets the main camera.
	var gui_managers = get_tree().get_nodes_in_group("gui_manager")
	if gui_managers != null and not gui_managers.empty():
		var gui_manager = gui_managers.front()
		var _r = drop_pod.connect("menu_opened", gui_manager, "_on_DropPod_menu_opened")
		_r = drop_pod.connect("menu_closed", gui_manager, "_on_DropPod_menu_closed")
		_r = drop_pod.connect("left_planet", gui_manager, "_on_DropPod_left_planet")
		_r = gui_manager.connect("return_to_ship", drop_pod, "_on_DropPodMenu_return_to_ship")
		_r = gui_manager.connect("return_to_ship", self, "_on_DropPodMenu_return_to_ship")
		_r = _local_player.connect("crystal_amount_changed", gui_manager, "_on_Player_crystal_amount_changed")
	
	
# ------------------------------------------------------------------------------
func _on_player_disconnected(peer_id):
	var player = get_node(str(peer_id))
	if player: player.queue_free()
	
	var drop_pod = get_node("DropPod" + str(peer_id))
	if drop_pod: drop_pod.queue_free()

	
# ------------------------------------------------------------------------------
func create_player(peer_id):
	_spawn_entity_and_drop(EntityType.PLAYER, false, peer_id)


# ------------------------------------------------------------------------------
func _on_player_died(player : Node2D):
	if player == _local_player:
		_cam_follow_point.set_target(player.drop_pod)
	
	remove_child(player)
	player.position = player.drop_pod.position
	player.health = base_player_health
	
	var respawn_timer = Timer.new()
	add_child(respawn_timer)
	respawn_timer.connect("timeout", self, "_on_respawn_timer_timout", 
		[player, respawn_timer])
	respawn_timer.start(3.0)


# ------------------------------------------------------------------------------
func _on_respawn_timer_timout(player : Node2D, respawn_timer : Timer):
	add_child(player)
	player.respawn_complete()
	respawn_timer.queue_free()
	
	if player == _local_player:
		_cam_follow_point.set_target(player)


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
	if Network.is_client():
		rpc_id(Network.SERVER_ID, "_request_leave_drop_pod", _entities.find(player))
	else:
		add_child(player)
	
	if Network.is_host():
		var entity_id = _entities.find(player)
		_entity_data[entity_id]["is_child"] = true
		
		for id in Network.setup_players:
			rpc_id(id, "_entity_exited_drop_pod", entity_id)
			
		
#-------------------------------------------------------------------------------
remote func _request_leave_drop_pod(entity_id):
	if Network.is_host():
		add_child(_entities[entity_id])
		_entity_data[entity_id]["is_child"] = true
		
		for id in Network.setup_players:
			rpc_id(id, "_entity_exited_drop_pod", entity_id)


#-------------------------------------------------------------------------------
remote func _entity_exited_drop_pod(entity_id):
	var sender_id = get_tree().get_rpc_sender_id()
	if Network.SERVER_ID == sender_id:
		add_child(_entities[entity_id])


#-------------------------------------------------------------------------------
func _on_DropPod_player_entered(player):
	if Network.is_client():
		rpc_id(Network.SERVER_ID, "_request_enter_drop_pod", _entities.find(player))
	else:
		remove_child(player)
	
	if Network.State.Hosting == Network.state:
		var entity_id = _entities.find(player)
		_entity_data[entity_id]["is_child"] = false
		
		for id in Network.setup_players:
			rpc_id(id, "_entity_entered_drop_pod", entity_id)
			

#-------------------------------------------------------------------------------
remote func _request_enter_drop_pod(entity_id):
	if Network.is_host():
		remove_child(_entities[entity_id])
		_entity_data[entity_id]["is_child"] = true
		
		for id in Network.setup_players:
			rpc_id(id, "_entity_entered_drop_pod", entity_id)

		
#-------------------------------------------------------------------------------
remote func _entity_entered_drop_pod(entity_id):
	var sender_id = get_tree().get_rpc_sender_id()
	if Network.SERVER_ID == sender_id:
		remove_child(_entities[entity_id])
	
	
#-------------------------------------------------------------------------------
func _on_local_DropPod_landed():
	_main_camera.limit_top = level_top


#-------------------------------------------------------------------------------
func _on_DropPodMenu_return_to_ship():
	_main_camera.limit_top = int(drop_height + camera_buffer)
	
	
#-------------------------------------------------------------------------------
