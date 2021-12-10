extends Node2D

onready var BulletScene = preload("res://scenes/Bullet.tscn")

var number_of_local_bullets = 0


# -----------------------------------------------------------------------------
remote func create_bullet(_position, _rotation, _z_index, bullet_name = null):
	var bullet = BulletScene.instance()
	
	bullet.position = _position
	bullet.rotation = _rotation
	bullet.z_index = _z_index
	
	if Network.is_online:
		var peer_id
		
		if not bullet_name:
			peer_id = get_tree().get_network_unique_id()
			bullet_name = str(peer_id) + str(number_of_local_bullets)
			rpc("create_bullet", _position, _rotation, _z_index, bullet_name)
		else:
			peer_id = get_tree().get_rpc_sender_id()
			
		bullet.set_name(bullet_name)
		bullet.set_network_master(Network.SERVER_ID)
		bullet.ignore_id = peer_id
	
	add_child(bullet)


# -----------------------------------------------------------------------------
