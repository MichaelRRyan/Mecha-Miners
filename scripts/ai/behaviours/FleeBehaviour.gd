class_name FleeBehaviour
extends Behaviour

var threat_detector = null


#-------------------------------------------------------------------------------
func _init():
	_name = "FleeBehaviour"
	_priority = 6


# ------------------------------------------------------------------------------
func _ready():
	threat_detector = _brain.find_node("ThreatDetector")


# ------------------------------------------------------------------------------
func _process(_delta):
	if _active and threat_detector.get_threats().empty():
		_brain.pop_behaviour()
	

# ------------------------------------------------------------------------------
