extends Control

onready var _login_tab = get_node("TabContainer/Login with Enjin")
onready var _link_wallet_tab = get_node("TabContainer/Link Wallet")


# ------------------------------------------------------------------------------
func _ready():
	Network.connect_to_server("127.0.0.1")
	var _r = Enjin.connect("get_user_info_response", self, "_on_Enjin_get_user_info_response")
	

# ------------------------------------------------------------------------------
func _on_BackButton_pressed():
	if get_tree().change_scene("res://scenes/ui/screens/TitleScreen.tscn") != OK:
		print_debug("Cannot change scene to TitleScreen.")


# ------------------------------------------------------------------------------
func _on_LoginPanel_user_logged_in():
	Enjin.get_current_user_info()
	
	
# ------------------------------------------------------------------------------
func _on_LoginPanel_user_logged_out():
	_link_wallet_tab.display_login_dialog()


# ------------------------------------------------------------------------------
func _on_Enjin_get_user_info_response(info, _error) -> void:
	
	# Checks the returned data is not null.
	if info != null:
		var identities = info.identities
		
		# Checks if the user has any identities.
		if identities.empty():
			_login_tab.display_logged_in_dialog(info.name, -1)
			_link_wallet_tab.display_connect_wallet_dialog(info.name)
			$TabContainer.current_tab = 2
		
		else:
			# Searches for an identity for this app.
			var app_identity = null
			for identity in identities:
				if identity.app.id == Enjin.APP_ID:
					app_identity = identity
					break
			
			# Checks if an identity was found.
			if app_identity != null and app_identity.wallet.ethAddress != null:
				_login_tab.display_logged_in_dialog(info.name, app_identity.id)
				_link_wallet_tab.display_already_linked_dialog()
					
			else:
				_login_tab.display_logged_in_dialog(info.name, -1)
				_link_wallet_tab.display_connect_wallet_dialog(info.name)
				$TabContainer.current_tab = 2


# ------------------------------------------------------------------------------
func _on_LinkWalletPanel_wallet_linked_successfully():
	$TabContainer.current_tab = 1
	_login_tab.display_wallet_linked()


# ------------------------------------------------------------------------------
