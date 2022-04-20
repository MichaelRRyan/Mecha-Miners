class_name FleeBehaviour
extends Behaviour

var threat_detector = null


# ------------------------------------------------------------------------------
func _ready():
	threat_detector = _brain.find_node("ThreatDetector")


# ------------------------------------------------------------------------------
func _process(_delta):
	if _active and threat_detector.get_threats() <= 0:
		_brain.pop_behaviour()
	

# ------------------------------------------------------------------------------
