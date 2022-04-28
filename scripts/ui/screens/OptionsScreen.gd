extends Control

const SLIDER_MAX_VALUE = 100.0


#-------------------------------------------------------------------------------
func _ready():
	$Options/SFXVolume/ProgressBar/HSlider.value = UserPreferences.get_sfx_volume() * SLIDER_MAX_VALUE
	$Options/MusicVolume/ProgressBar/HSlider.value = UserPreferences.get_music_volume() * SLIDER_MAX_VALUE
	$Options/SFXVolume/CheckButton.pressed = not UserPreferences.get_sfx_muted()
	$Options/MusicVolume/CheckButton.pressed = not UserPreferences.get_music_muted()
	$Options/FullscreenToggle/CheckButton.pressed = UserPreferences.get_fullscreen()
	$Options/DefaultIP/LineEdit.text = UserPreferences.get_default_ip()


#-------------------------------------------------------------------------------
func _on_SFXVolumeSlider_value_changed(value):
	UserPreferences.set_sfx_volume(value / SLIDER_MAX_VALUE)
	
	
#-------------------------------------------------------------------------------
func _on_MuteSFXButton_toggled(button_pressed):
	UserPreferences.set_sfx_muted(not button_pressed)


#-------------------------------------------------------------------------------
func _on_MuteMusicButton_toggled(button_pressed):
	UserPreferences.set_music_muted(not button_pressed)


#-------------------------------------------------------------------------------
func _on_MusicVolumeSlider_value_changed(value):
	UserPreferences.set_music_volume(value / SLIDER_MAX_VALUE)
	

#-------------------------------------------------------------------------------
func _on_FullscreenButton_toggled(button_pressed):
	UserPreferences.set_fullscreen(button_pressed)


#-------------------------------------------------------------------------------
func _on_BackButton_pressed():
	if get_tree().change_scene("res://scenes/ui/screens/TitleScreen.tscn") != OK:
		print_debug("Cannot change scene to TitleScreen.")
	

#-------------------------------------------------------------------------------
func _on_DefaultIP_text_changed(new_text):
	UserPreferences.set_default_ip(new_text)
	
	
#-------------------------------------------------------------------------------
