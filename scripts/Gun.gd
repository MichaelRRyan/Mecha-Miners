extends Sprite

onready var BulletScene = preload("res://scenes/Bullet.tscn")

export var cooldown = 0.15
var bullet_container = null


func _ready():
	var containers = get_tree().get_nodes_in_group("bullet_container")
	if containers and not containers.empty():
		bullet_container = containers[0]
	

func shoot():
	# If there's a reference to a bullet container and cooldown has expired.
	if bullet_container and $CooldownTimer.is_stopped():
		 
		var bullet = BulletScene.instance()
		
		bullet.rotation = $Tip.global_rotation
		bullet.position = $Tip.global_position
		bullet.z_index = z_index - 1
		
		bullet_container.add_child(bullet)
		$CooldownTimer.start(cooldown)
