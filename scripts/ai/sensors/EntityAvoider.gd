extends Area2D

export(float) var avoidance_force_modifier = 5.0

var _entites_to_avoid = []
var _brain : AIBrain = null


#-------------------------------------------------------------------------------
func get_entities_to_avoid() -> Array:
	return _entites_to_avoid


#-------------------------------------------------------------------------------
func _on_EntityAvoidanceSensor_body_entered(body : Node2D):
	# Adds the body to the container if it's not a parent.
	if not body.is_a_parent_of(self):
		_entites_to_avoid.append(body)
		
		if not body.is_connected("died", self, "_on_entity_died"):
			var _r = body.connect("died", self, "_on_entity_died", [body])


#-------------------------------------------------------------------------------
func _on_EntityAvoidanceSensor_body_exited(body):
	if _entites_to_avoid.has(body):
		_entites_to_avoid.erase(body)


#-------------------------------------------------------------------------------
func _on_entity_died(body):
	if _entites_to_avoid.has(body):
		_entites_to_avoid.erase(body)
	
	
#-------------------------------------------------------------------------------
func _ready():
	# Gets the parent as the brain if it's an AIbrain.
	var parent = get_parent()
	if parent != null and parent is AIBrain:
		_brain = parent


#-------------------------------------------------------------------------------
func _process(delta):
	var force = Vector2.ZERO
	for entity in _entites_to_avoid:
		var vec_from = global_position - entity.position
		force += vec_from
	
	_brain.subject.accelerate(force * avoidance_force_modifier * delta)


#-------------------------------------------------------------------------------
