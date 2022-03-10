extends Node
class_name AIBehaviours

#-------------------------------------------------------------------------------
class Behaviour:
	extends Node
	
	var _brain = null setget set_brain
	
	
	#---------------------------------------------------------------------------
	func set_brain(brain):
		_brain = brain
	
	
	#---------------------------------------------------------------------------
	func _process(_delta):
		pass


#-------------------------------------------------------------------------------
class IdleBehaviour:
	extends Behaviour
	
	func _process(_delta):
		pass


#-------------------------------------------------------------------------------
