extends Node2D

var _entity_sensor = null
var _brain : AIBrain = null
var _has_weapon = false
var _fight_or_flight : FightOrFlight.DecisionNode = null # A decision tree.
var _threats = []


#-------------------------------------------------------------------------------
func add_threat(entity):
	if not _threats.has(entity):
		_threats.append(entity)


#-------------------------------------------------------------------------------
func _ready():
	# Gets the parent as the brain if it's an AI brain.
	var parent = get_parent()
	if parent != null and parent is AIBrain:
		_brain = parent
		
		_entity_sensor = _brain.find_node("EntitySensor")
		
		if _entity_sensor == null:
			print_debug("Can't find EntitySensor.")
		
		_construct_decision_tree()
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
func _construct_decision_tree():
	
	# Takes a shorthand alias of the class.
	var fof = FightOrFlight
	
	# Creates the second half of the tree to place into the first half.
	var second_branch = fof.HasLowHealth.new() \
		.map(true, fof.Flee.new()) \
		.map(false, fof.AssessRisk.new() \
			.map(fof.Values.HIGH, fof.AssessPotentialReward.new() \
				.map(fof.Values.LOW, fof.CalculateBravado.new(0.1) \
					.map(false, fof.Flee.new()) \
					.map(true, fof.Attack.new())) \
				.map(fof.Values.MEDIUM, fof.CalculateBravado.new(0.5) \
					.map(false, fof.Flee.new()) \
					.map(true, fof.Attack.new())) \
				.map(fof.Values.HIGH, fof.CalculateBravado.new(0.8) \
					.map(false, fof.Flee.new()) \
					.map(true, fof.Attack.new()))) \
			.map(fof.Values.MEDIUM, fof.AssessPotentialReward.new() \
				.map(fof.Values.LOW, fof.Ignore.new()) \
				.map(fof.Values.MEDIUM, fof.CalculateBravado.new(0.5) \
					.map(false, fof.Ignore.new()) \
					.map(true, fof.Attack.new())) \
				.map(fof.Values.HIGH, fof.CalculateBravado.new(0.8) \
					.map(false, fof.Ignore.new()) \
					.map(true, fof.Attack.new()))) \
			.map(fof.Values.LOW, fof.AssessPotentialReward.new() \
				.map(fof.Values.LOW, fof.Ignore.new()) \
				.map(fof.Values.MEDIUM, fof.CalculateBravado.new(0.7) \
					.map(false, fof.Ignore.new()) \
					.map(true, fof.Attack.new())) \
				.map(fof.Values.HIGH, fof.Attack.new())))
	
	# Creates the first half of the tree and places the second half into it.
	_fight_or_flight = fof.HasWeapon.new() \
		.map(false, fof.AssessThreatLevel.new() \
			.map(fof.Values.LOW, fof.Ignore.new()) \
			.map(fof.Values.MEDIUM, fof.CalculateBravado.new(0.5) \
				.map(false, fof.Flee.new()) \
				.map(true, fof.Ignore.new())) \
			.map(fof.Values.HIGH, fof.CalculateBravado.new(0.2) \
				.map(false, fof.Flee.new()) \
				.map(true, fof.Ignore.new()))) \
		.map(true, fof.AssessThreatLevel.new() \
			.map(fof.Values.LOW, fof.AssessPotentialReward.new() \
				.map(fof.Values.LOW, fof.Ignore.new()) \
				.map(fof.Values.MEDIUM, fof.CalculateBravado.new(0.7) \
					.map(false, fof.Ignore.new()) \
					.map(true, fof.Attack.new())) \
				.map(fof.Values.HIGH, fof.Attack.new())) \
			.map(fof.Values.MEDIUM, second_branch) \
			.map(fof.Values.HIGH, second_branch))


#-------------------------------------------------------------------------------
