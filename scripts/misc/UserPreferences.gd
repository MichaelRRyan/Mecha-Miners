extends Node

var _sfx_volume = 0.5 setget set_sfx_volume, get_sfx_volume
var _music_volume = 0.5 setget set_music_volume, get_music_volume
var _sfx_muted = false setget set_sfx_muted, get_sfx_muted
var _music_muted = false setget set_music_muted, get_music_muted

var _default_ip = "127.0.0.1" setget set_default_ip, get_default_ip


#-------------------------------------------------------------------------------
func set_sfx_volume(volume : float) -> void:
	_sfx_volume = volume


#-------------------------------------------------------------------------------
func get_sfx_volume() -> float:
	return _sfx_volume


#-------------------------------------------------------------------------------
func set_music_volume(volume : float) -> void:
	_music_volume = volume


#-------------------------------------------------------------------------------
func get_music_volume() -> float:
	return _music_volume


#-------------------------------------------------------------------------------
func set_sfx_muted(flag : bool) -> void:
	_sfx_muted = flag


#-------------------------------------------------------------------------------
func get_sfx_muted() -> bool:
	return _sfx_muted


#-------------------------------------------------------------------------------
func set_music_muted(flag : bool) -> void:
	_music_muted = flag


#-------------------------------------------------------------------------------
func get_music_muted() -> bool:
	return _music_muted


#-------------------------------------------------------------------------------
func set_fullscreen(flag : bool) -> void:
	OS.window_fullscreen = flag


#-------------------------------------------------------------------------------
func get_fullscreen() -> bool:
	return OS.window_fullscreen


#-------------------------------------------------------------------------------
func set_default_ip(value : String) -> void:
	_default_ip = value


#-------------------------------------------------------------------------------
func get_default_ip() -> String:
	return _default_ip


#-------------------------------------------------------------------------------
