class_name IdleBehaviour
extends Behaviour


#---------------------------------------------------------------------------
func _init():
	_name = "IdleBehaviour"


#---------------------------------------------------------------------------
func _ready() -> void:
	var mineral_sensor : Node2D = _brain.find_node("MineralSensor")
	if mineral_sensor:
		var _v = mineral_sensor.connect("mineral_found", self, "_on_MineralSensor_mineral_found")
	
	var item_sensor : Node2D = _brain.find_node("ItemSensor")
	if item_sensor:
		var _v = item_sensor.connect("item_found", self, "_on_ItemSensor_item_found")
		
		
#-------------------------------------------------------------------------------
func _process(_delta):
	if _active:
		var behaviour = ExploreBehaviour.new()
		_brain.add_behaviour(behaviour)
		
		
#-------------------------------------------------------------------------------
func _on_MineralSensor_mineral_found(_mineral_cell : Vector2) -> void:
	var behaviour = HarvestMineralsBehaviour.new()
	_brain.request_add_behaviour(behaviour)


#-------------------------------------------------------------------------------
func _on_ItemSensor_item_found(_item_obj : Node2D) -> void:
	var behaviour = CollectItemsBehaviour.new()
	_brain.request_add_behaviour(behaviour)


#-------------------------------------------------------------------------------
