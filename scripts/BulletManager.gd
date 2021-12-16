extends Node2D

onready var BulletScene = preload("res://scenes/Bullet.tscn")

var number_of_local_bullets = 0


# -----------------------------------------------------------------------------
remote func create_bullet(_position, _rotation, _z_index, _name = null):
	var bullet = BulletScene.instance()
	
	var unit_direction = Vector2(cos(_rotation), sin(_rotation)).normalized()
	bullet.position = _position + unit_direction * bullet.width
	bullet.rotation = _rotation
	bullet.z_index = _z_index
	
	if Network.is_online: 
		setup_networking_attributes(bullet, _position, _rotation, _z_index, _name)
	
	add_child(bullet)


# -----------------------------------------------------------------------------
func setup_networking_attributes(bullet, _position, _rotation, _z_index, _name):
	
	var peer_id
		
	if not _name:
		peer_id = get_tree().get_network_unique_id()
		_name = str(peer_id) + str(number_of_local_bullets)
		rpc("create_bullet", _position, _rotation, _z_index, _name)
	else:
		peer_id = get_tree().get_rpc_sender_id()
		
	bullet.set_name(_name)
	bullet.set_network_master(Network.SERVER_ID)
	bullet.ignore_id = peer_id


# -----------------------------------------------------------------------------
