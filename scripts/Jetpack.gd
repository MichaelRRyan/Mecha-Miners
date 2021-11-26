extends Node2D

export var acceleration = 250.0

var holder = null
var flying = false
var flying_last_frame = false


# -----------------------------------------------------------------------------
func _ready():
	# Tries to the equip the jetpack to the parent.
	equip(get_parent())


# -----------------------------------------------------------------------------
func _physics_process(_delta):
	flying_last_frame = flying
	flying = false


# -----------------------------------------------------------------------------
func equip(equiper : Node2D):
	# Sets the equiper as the jetpack holder if it has the necessary method.
	if equiper and equiper.has_method("accelerate"):
		holder = equiper
		process_priority = equiper.process_priority - 1


# -----------------------------------------------------------------------------
func activate(delta):
	if holder:
		holder.accelerate(Vector2(0.0, -acceleration * delta))
		flying = true


# -----------------------------------------------------------------------------
func is_flying():
	return flying or flying_last_frame


# -----------------------------------------------------------------------------
