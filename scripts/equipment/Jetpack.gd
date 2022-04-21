extends Node2D

export var acceleration = 250.0
export var velocity_multiplier = 1.5

var holder = null
var flying = false
var flying_last_frame = false


# -----------------------------------------------------------------------------
func _ready():
	# Tries to the equip the jetpack to the parent.
	equip(get_parent())


# -----------------------------------------------------------------------------
func _process(_delta):
	flying_last_frame = flying
	flying = false
	$ParticlesLarge.emitting = flying_last_frame
	$ParticlesSmall.emitting = flying_last_frame


# -----------------------------------------------------------------------------
func equip(equiper : Node2D):
	# Sets the equiper as the jetpack holder if it has the necessary method.
	if equiper and equiper.has_method("accelerate") and equiper.has_method("get_velocity"):
		holder = equiper
		process_priority = equiper.process_priority - 1


# -----------------------------------------------------------------------------
func activate(delta):
	if holder:
		
		# Adds extra force to the acceleration if moving downwards.
		var velocity = holder.get_velocity()
		var accel = -acceleration
		if velocity.y > 0:
			accel -= velocity.y * velocity_multiplier
			
		holder.accelerate(Vector2(0.0, accel * delta))
		flying = true


# -----------------------------------------------------------------------------
func is_flying():
	return flying or flying_last_frame


# -----------------------------------------------------------------------------
