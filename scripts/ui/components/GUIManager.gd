extends CanvasLayer

signal menu_toggled(opened)
signal return_to_ship()


var _current_screen = null


# -----------------------------------------------------------------------------
func _on_Player_crystal_amount_changed(total_crystals):
	$CrystalsAmount/Amount.text = str(total_crystals)


# -----------------------------------------------------------------------------
func _on_DropPod_menu_opened():
	_switch_screen($DropPodMenu)


# -----------------------------------------------------------------------------
func _on_DropPod_menu_closed():
	_switch_screen(null)


# -----------------------------------------------------------------------------
func _switch_screen(new_screen):
	var screen_is_valid = new_screen != null
	
	if _current_screen:
		_current_screen.hide()
	
	_current_screen = new_screen
	
	if _current_screen:
		_current_screen.show()
		
	emit_signal("menu_toggled", screen_is_valid)


# -----------------------------------------------------------------------------
func _on_DropPodMenu_gems_amount_changed(amount):
	$CrystalsAmount/Amount.text = str(amount)


# -----------------------------------------------------------------------------
func _on_DropPodMenu_return_to_ship():
	_switch_screen(null)
	emit_signal("return_to_ship")


# -----------------------------------------------------------------------------
func _on_DropPod_left_planet():
	$DropPodMenu._on_DropPod_left_planet()


# -----------------------------------------------------------------------------
