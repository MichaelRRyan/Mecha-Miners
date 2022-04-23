extends Control


onready var _login_tab = get_node("TabContainer/Login with Enjin")


# ------------------------------------------------------------------------------
func _ready():
	var _r = Enjin.connect("get_user_info_response", self, "_on_Enjin_get_user_info_response")
	Network.connect_to_server("127.0.0.1")
	


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
			_login_tab.display_logged_in_dialog(info.name, false)
		
		else:
			# Searches for an identity for this app.
			var app_identity = null
			for identity in identities:
				if identity.app.id == Enjin.APP_ID:
					app_identity = identity
					break
			
			# Checks if an identity was found.
			if app_identity != null and app_identity.wallet.ethAddress != null:
				_login_tab.display_logged_in_dialog(info.name, true)
					
			else:
				_login_tab.display_logged_in_dialog(info.name, false)


# ------------------------------------------------------------------------------
func _request_identity():
	Network.request_identity(Enjin._user_id, "0xa9fA6bb88A99C8f1344eB87E74c60991299d6405")
	

# ------------------------------------------------------------------------------
