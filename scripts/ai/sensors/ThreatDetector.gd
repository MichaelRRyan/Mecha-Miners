extends Node2D

var _entity_sensor = null
var _brain : AIBrain = null
var _has_weapon = false

#-------------------------------------------------------------------------------
func _ready():
	# Gets the parent as the brain if it's an AI brain.
	var parent = get_parent()
	if parent != null and parent is AIBrain:
		_brain = parent
		
		_entity_sensor = _brain.find_node("EntitySensor")
		
		if _entity_sensor == null:
			print_debug("Can't find EntitySensor.")
		
		call_deferred("_check_for_guns")
		

#-------------------------------------------------------------------------------
func _check_for_guns():
	var weapon_count = _brain.subject.get_gun_count()
	if weapon_count > 0:
		_has_weapon = true


#-------------------------------------------------------------------------------
func _on_EntitySensor_entity_spotted(_entity):
	if _has_weapon:
		_brain.request_add_behaviour(AttackBehaviour.new())


#-------------------------------------------------------------------------------
