class_name AttackBehaviour
extends Behaviour

var _terrain = null
var _entity_sensor = null


#-------------------------------------------------------------------------------
func _init():
	_name = "AttackBehaviour"
	_priority = 5


#-------------------------------------------------------------------------------
func _ready() -> void:
	# Gets the terrain.
	var terrain_container = get_tree().get_nodes_in_group("terrain")
	if not terrain_container.empty():
		_terrain = terrain_container.front()

	# Gets the entity sensor.
	_entity_sensor = _brain.find_node("EntitySensor")
	if _entity_sensor == null:
		set_process(false)
		_brain.pop_behaviour()
		return
	
	# Checks we have a weapon.
	var weapon_count = _brain.subject.get_gun_count()
	if weapon_count == 0:
		print_debug("No suitable equipment found.")
		set_process(false)
		_brain.pop_behaviour()
		return
	
	# Adds pursue as a sub behaviour.
	_add_sub_behaviour(PursueBehaviour.new(false))
	

#-------------------------------------------------------------------------------
func _process(_delta):
	var entities = _entity_sensor.get_entities_in_range()
	if not entities.empty():
		_brain.set_target(entities.front().global_position)
		_brain.subject.attack()
	else:
		set_process(false)
		_brain.pop_behaviour()


#-------------------------------------------------------------------------------
