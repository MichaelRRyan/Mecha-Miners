extends Control

const APP_ID = 6145

onready var _emailField : LineEdit = find_node("EmailField")
onready var _passwordField : LineEdit = find_node("PasswordField")
onready var _error_label : Label = find_node("ErrorLabel")


# ------------------------------------------------------------------------------
func _ready():
	var _r
	_r = Enjin.connect("login_response", self, "_on_Enjin_login_response")
	_r = Enjin.connect("get_user_info_response", self, "_on_Enjin_get_user_info_response")


# ------------------------------------------------------------------------------
func _on_LoginButton_pressed():
	if _emailField and _passwordField:
		var username = _emailField.text
		var password = _passwordField.text
		
		if username.empty() or password.empty():
			_display_error_message("Neither field can be left blank.")
			return
			
		Enjin.login(username, password)


#-------------------------------------------------------------------------------
func _on_Enjin_login_response(successful : bool, _error) -> void:
	if successful:
		Enjin.get_current_user_info()
	else:
		_display_error_message("Incorrect username or password.")


#-------------------------------------------------------------------------------
func _on_Enjin_get_user_info_response(info, _error) -> void:
	# Checks the returned data is not null.
	if info != null:
		var identities = info.identities
		
		# Checks if the user has any identities.
		if identities.empty():
			_display_error_message("No identities.")
		
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
					_display_error_message("wallet " + app_identity.wallet.ethAddress)
				else:
					_display_error_message("User has an identity but no linked wallet.")
			else:
				_display_error_message("User has no identity on this platform.")
				
	
# ------------------------------------------------------------------------------
func _display_error_message(message : String) -> void:
	if _error_label:
		_error_label.text = message


# ------------------------------------------------------------------------------

