extends Control

const APP_ID = 6145

onready var _login_tab = get_node("TabContainer/Login with Enjin")


# ------------------------------------------------------------------------------
func _ready():
	var _r = Enjin.connect("get_user_info_response", self, "_on_Enjin_get_user_info_response")


# ------------------------------------------------------------------------------
func _on_BackButton_pressed():
	if get_tree().change_scene("res://scenes/ui/screens/TitleScreen.tscn") != OK:
		print_debug("Cannot change scene to TitleScreen.")


# ------------------------------------------------------------------------------
func _on_LoginPanel_user_logged_in():
	Enjin.get_current_user_info()


# ------------------------------------------------------------------------------
func _on_Enjin_get_user_info_response(info, _error) -> void:
	# Checks the returned data is not null.
	if info != null:
		var identities = info.identities
		
		# Checks if the user has any identities.
		if identities.empty():
			_login_tab._display_error_message("No identities.")
			# TODO: Create identity for them.
		
		else:
			# Searches for an identity for this app.
			var app_identity = null
			for identity in identities:
				if identity.app.id == APP_ID:
					app_identity = identity
					break
			
			# Checks if an identity was found.
			if app_identity != null:
				if app_identity.wallet.ethAddress != null:
					_login_tab._display_error_message("wallet " + app_identity.wallet.ethAddress)
				else:
					_login_tab._display_error_message("User has an identity but no linked wallet.")
					# TODO: Link wallet.
			else:
				_login_tab._display_error_message("User has no identity on this platform.")
				# TODO: Create identity for them.


# ------------------------------------------------------------------------------
