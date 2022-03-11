extends Node2D

enum Type {
	NULL,
	DRILL,
	GUN,
}

export var automatic = false

var tool_type = Type.NULL
var _holder = null


func set_holder(holder : Node2D):
	_holder = holder


func activate():
	pass
