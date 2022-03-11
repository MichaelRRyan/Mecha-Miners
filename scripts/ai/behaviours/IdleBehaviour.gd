class_name IdleBehaviour
extends Behaviour


#---------------------------------------------------------------------------
func _ready():
	var sensor : Node2D = _brain.find_node("MineralSensor")
	if sensor:
		var _v = sensor.connect("mineral_found", self, "_on_MineralSensor_mineral_found")
		
		
#-------------------------------------------------------------------------------
func _on_MineralSensor_mineral_found(mineral_cell):
	if get_parent() != null:
		_brain.change_behaviour(HarvestMineralsBehaviour.new(mineral_cell))


#---------------------------------------------------------------------------
func get_class() -> String:
	return "IdleBehaviour"


#-------------------------------------------------------------------------------
