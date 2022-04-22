extends ProgressBar


# ------------------------------------------------------------------------------
func _ready() -> void:
	var _r = $HSlider.connect("value_changed", self, "_on_HSlider_value_changed")
	value = $HSlider.value


# ------------------------------------------------------------------------------
func _on_HSlider_value_changed(new_value : float) -> void:
	value = new_value


# ------------------------------------------------------------------------------
