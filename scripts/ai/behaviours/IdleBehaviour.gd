class_name IdleBehaviour
extends Behaviour


#---------------------------------------------------------------------------
func _init():
	_name = "IdleBehaviour"
		
		
#-------------------------------------------------------------------------------
func _process(_delta):
	if _active:
		var behaviour = ExploreBehaviour.new()
		_brain.add_behaviour(behaviour)
		
		
#-------------------------------------------------------------------------------
