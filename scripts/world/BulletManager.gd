extends Node2D

onready var BulletScene = preload("res://scenes/equipment/Bullet.tscn")

var number_of_local_bullets = 0
var player_manager = null


# -----------------------------------------------------------------------------
func _ready():
	var player_managers = get_tree().get_nodes_in_group("player_manager")
	if player_managers and !player_managers.empty():
		if player_managers[0].has_method("get_player_by_peer_id"):
			player_manager = player_managers[0]
	

# -----------------------------------------------------------------------------
func create_bullet(_position, _rotation, _z_index, root_position, entity_name):
	
	var ignore_rid = player_manager.get_node(entity_name).get_rid()
	
	var bullet = __create_bullet(_position, _rotation, _z_index, 
		root_position, ignore_rid)
		
	if Network.is_online: 
		handle_networking(bullet, _position, _rotation, _z_index, root_position, entity_name)


# -----------------------------------------------------------------------------
func __create_bullet(_position, _rotation, _z_index, root_position, ignore_rid):
	var bullet = BulletScene.instance()
	
	bullet.position = _position
	bullet.start_position = root_position
	bullet.rotation = _rotation
	bullet.z_index = _z_index
	bullet.ignore_rid = ignore_rid
	
	add_child(bullet)
	return bullet


# -----------------------------------------------------------------------------
func handle_networking(bullet, _position, _rotation, _z_index, root_position, entity_name):
	var peer_id = get_tree().get_network_unique_id()
	var bullet_name = str(peer_id) + str(number_of_local_bullets)
	
	for id in Network.setup_players:
		rpc_id(id, "create_remote_bullet", _position, _rotation, _z_index, root_position, bullet_name, entity_name)
		
	setup_networking_attributes(bullet, bullet_name)


# -----------------------------------------------------------------------------
func setup_networking_attributes(bullet, bullet_name):
	bullet.set_name(bullet_name)
	bullet.set_network_master(Network.SERVER_ID)


# -----------------------------------------------------------------------------
remote func create_remote_bullet(_position, _rotation, _z_index, root_position, bullet_name, entity_name):
	if not player_manager: return
	
	var ignore_rid = player_manager.get_node(entity_name).get_rid()
	
	var bullet = __create_bullet(_position, _rotation, _z_index, root_position, 
		ignore_rid)
		
	setup_networking_attributes(bullet, bullet_name)
	

# -----------------------------------------------------------------------------
