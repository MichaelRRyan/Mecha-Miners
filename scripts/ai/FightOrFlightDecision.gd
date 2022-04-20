class_name FightOrFlight

enum Values {
	LOW = 0,
	MEDIUM = 1,
	HIGH = 2,
}


# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
class DecisionNode:
	
	var _branches = {}
	
	# --------------------------------------------------------------------------
	func make_decision(_brain : AIBrain, _entity : Node2D) -> void:
		assert(false)
		
	# --------------------------------------------------------------------------
	func map(key, value : DecisionNode) -> DecisionNode:
		_branches[key] = value
		return self
	
	# --------------------------------------------------------------------------
	func _branch(result, brain : AIBrain, entity : Node2D) -> void:
		if _branches.has(result):
			_branches[result].make_decision(brain, entity)
		else:
			print_debug("No branch mapped to result of " + str(result) + ".")


# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
class HasWeapon:
	extends DecisionNode
	
	# --------------------------------------------------------------------------
	func make_decision(brain : AIBrain, entity : Node2D) -> void:
		if brain.subject.get_gun_count() > 0:
			_branch(true, brain, entity)
		else:
			_branch(false, brain, entity)


# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
class AssessThreatLevel:
	extends DecisionNode
	
	# The squared distance at which an entity becomes a threatening.
	const DANGER_DISTANCE_SQ = 50.0 * 50.0
	
	# --------------------------------------------------------------------------
	func make_decision(brain : AIBrain, entity : Node2D) -> void:
		if entity.get_gun_count() <= 0:
			_branch(Values.LOW, brain, entity)
			
		else:
			var dist = entity.global_position - brain.subject.global_position
			var dist_sq = dist.length_squared()
			
			if dist_sq > DANGER_DISTANCE_SQ:
				_branch(Values.MEDIUM, brain, entity)
			else:
				_branch(Values.HIGH, brain, entity)


# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
class AssessPotentialReward:
	extends DecisionNode
	
	# TODO: Move to a global script.
	const WORLD_HEIGHT = 350.0 * 16.0
	const ONE_OVER_WORLD_HEIGHT = 1.0 / WORLD_HEIGHT
	
	# The threshold at which point the reward changes.
	const MEDIUM_REWARD_THRESHOLD = 0.3
	const HIGH_REWARD_THRESHOLD = 0.7
	
	# --------------------------------------------------------------------------
	func make_decision(brain : AIBrain, entity : Node2D) -> void:
		var depth = entity.global_position.y * ONE_OVER_WORLD_HEIGHT

		if depth < MEDIUM_REWARD_THRESHOLD:
			_branch(Values.LOW, brain, entity)
		elif depth < HIGH_REWARD_THRESHOLD:
			_branch(Values.MEDIUM, brain, entity)
		else:
			_branch(Values.HIGH, brain, entity)


# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
class HasLowHealth:
	extends DecisionNode
	
	# When health goes below this number, it's considered to be low.
	const LOW_HEALTH_THRESHOLD = 2.0
	
	# --------------------------------------------------------------------------
	func make_decision(brain : AIBrain, entity : Node2D) -> void:
		if brain.subject.get_health() < LOW_HEALTH_THRESHOLD:
			_branch(true, brain, entity)
		else:
			_branch(false, brain, entity)


# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
class CalculateBravado:
	extends DecisionNode
	
	var _certainty = 0.0
	
	# --------------------------------------------------------------------------
	func _init(certainty : float): 
		_certainty = certainty
	
	# --------------------------------------------------------------------------
	func make_decision(brain : AIBrain, entity : Node2D) -> void:
		_branch(brain.bravado(_certainty), brain, entity)


# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
class AssessRisk:
	extends DecisionNode
	
	# The threshold at which point the risk changes.
	const MEDIUM_RISK_THRESHOLD = 0.5
	const HIGH_RISK_THRESHOLD = 0.8
	
	# --------------------------------------------------------------------------
	func make_decision(brain : AIBrain, entity : Node2D) -> void:
		var ideal_value = brain.get_ideal_value()
		var real_value = brain.get_real_value()
		var interp = real_value / ideal_value

		if interp < MEDIUM_RISK_THRESHOLD:
			_branch(Values.LOW, brain, entity)
		elif interp < HIGH_RISK_THRESHOLD:
			_branch(Values.MEDIUM, brain, entity)
		else:
			_branch(Values.HIGH, brain, entity)


# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
class Attack:
	extends DecisionNode
	
	# --------------------------------------------------------------------------
	func make_decision(brain : AIBrain, entity : Node2D) -> void:
		var threat_detector = brain.find_node("ThreatDetector")
		if threat_detector != null:
			threat_detector.add_threat(entity)
			brain.request_add_behaviour(AttackBehaviour.new())
		else:
			print_debug("No threat detector found on controller.")


# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
class Flee:
	extends DecisionNode
	
	# --------------------------------------------------------------------------
	func make_decision(brain : AIBrain, entity : Node2D) -> void:
		var threat_detector = brain.find_node("ThreatDetector")
		if threat_detector != null:
			threat_detector.add_threat(entity)
			brain.request_add_behaviour(FleeBehaviour.new())
		else:
			print_debug("No threat detector found on controller.")
		

# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
class Ignore:
	extends DecisionNode
	
	# --------------------------------------------------------------------------
	func make_decision(_brain : AIBrain, _entity : Node2D) -> void:
		pass # Does nothing.


# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
