extends Area2D

var _brain : AIBrain = null
var _player_manager = null

# Decision trees.
var _fight_or_flight : FightOrFlight.DecisionNode = null
var _agitated_fight_or_flight : FightOrFlight.DecisionNode = null

var _threats = []
var _attacker_rids = []


#-------------------------------------------------------------------------------
func add_threat(entity):
	if not _threats.has(entity):
		_threats.append(entity)


#-------------------------------------------------------------------------------
func get_threats() -> Array:
	return _threats
	
	
#-------------------------------------------------------------------------------
func get_attacker_rids() -> Array:
	return _attacker_rids


#-------------------------------------------------------------------------------
func _ready():
	# Gets the parent as the brain if it's an AI brain.
	var parent = get_parent()
	if parent != null and parent is AIBrain:
		_brain = parent
		
		var managers = get_tree().get_nodes_in_group("player_manager")
		if managers and not managers.empty():
			_player_manager = managers.front()
		else:
			print_debug("Can't find the player manager.")
		
		_construct_decision_trees()
		call_deferred("_connect_to_damage_signal")


#-------------------------------------------------------------------------------
func _connect_to_damage_signal():
	var _r = _brain.subject.connect("damage_taken", self, "_on_subject_damage_taken")


#-------------------------------------------------------------------------------
func _on_subject_damage_taken(_damage, source):
	if source != null and source.get("ignore_rid") != null:
		var rid = source.ignore_rid
		if not _attacker_rids.has(rid):
			_attacker_rids.append(source.ignore_rid)
		
		var entity = _player_manager.get_entity_by_rid(rid)
		if entity:
			_agitated_fight_or_flight.make_decision(_brain, entity)
		else:
			print_debug("No entity found with an RID of " + str(rid))
	
	
#-------------------------------------------------------------------------------
func _on_EntitySensor_entity_spotted(entity):
	_fight_or_flight.make_decision(_brain, entity)
	
	if not entity.is_connected("died", self, "_on_entity_died"):
		var _r = entity.connect("died", self, "_on_entity_died", [entity])
		
		
#-------------------------------------------------------------------------------
func _on_EntitySensor_entity_out_of_sight(entity):
	if _threats.has(entity):
		_threats.erase(entity)


#-------------------------------------------------------------------------------
func _on_ThreatDetector_body_entered(body):
	if not body.is_a_parent_of(self):
		_fight_or_flight.make_decision(_brain, body)
		
		if not body.is_connected("died", self, "_on_entity_died"):
			var _r = body.connect("died", self, "_on_entity_died", [body])


#-------------------------------------------------------------------------------
func _on_entity_died(entity):
	if _threats.has(entity):
		_threats.erase(entity)
	
	
#-------------------------------------------------------------------------------
func _construct_decision_trees():
	
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
			.map(fof.Values.MEDIUM, fof.CalculateBravado.new(0.8) \
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
	
	# Creates the agitated fight or flight tree.
	_agitated_fight_or_flight = fof.HasWeapon.new() \
		.map(false, fof.Flee.new()) \
		.map(true, fof.HasLowHealth.new() \
			.map(true, fof.Flee.new()) \
			.map(false, fof.AssessRisk.new() \
				.map(fof.Values.LOW, fof.Attack.new()) \
				.map(fof.Values.MEDIUM, fof.Attack.new()) \
				.map(fof.Values.HIGH, fof.AssessPotentialReward.new() \
					.map(fof.Values.LOW, fof.CalculateBravado.new(0.2) \
						.map(false, fof.Flee.new()) \
						.map(true, fof.Attack.new())) \
					.map(fof.Values.MEDIUM, fof.CalculateBravado.new(0.5) \
						.map(false, fof.Flee.new()) \
						.map(true, fof.Attack.new())) \
					.map(fof.Values.HIGH, fof.CalculateBravado.new(0.8) \
						.map(false, fof.Flee.new()) \
						.map(true, fof.Attack.new())))))


#-------------------------------------------------------------------------------
