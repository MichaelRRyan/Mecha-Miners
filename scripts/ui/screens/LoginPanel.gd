extends Control

signal user_logged_in()
signal user_logged_out()

onready var _email_field : LineEdit = find_node("EmailField")
onready var _password_field : LineEdit = find_node("PasswordField")
onready var _error_label : Label = find_node("ErrorLabel")
onready var _login_button : Button = find_node("LoginButton")


# ------------------------------------------------------------------------------
func _ready():
	var _r = Enjin.connect("login_response", self, "_on_Enjin_login_response")


# ------------------------------------------------------------------------------
func _on_LoginButton_pressed():
	if _email_field and _password_field:
		var username = _email_field.text
		var password = _password_field.text
		
		if username.empty() or password.empty():
			_display_error_message("Neither field can be left blank.")
			return
			
		_display_logging_in_dialog()
		Enjin.login(username, password)


#-------------------------------------------------------------------------------
func _on_Enjin_login_response(successful : bool, _error) -> void:
	if successful:
		emit_signal("user_logged_in")
	else:
		$LoggingInDialog.hide()
		$LoginDialog.show()
		_display_error_message("Incorrect username or password.")

	
# ------------------------------------------------------------------------------
func _display_error_message(message : String) -> void:
	if _error_label:
		_error_label.text = message


# ------------------------------------------------------------------------------
func _on_EmailField_text_entered(_new_text) -> void:
	_password_field.grab_focus()


# ------------------------------------------------------------------------------
func _on_PasswordField_text_entered(_new_text) -> void:
	_on_LoginButton_pressed()
	_login_button.grab_focus()


# ------------------------------------------------------------------------------
func _display_logging_in_dialog() -> void:
	$LoginDialog.hide()
	$LoggingInDialog.show()
	$LoggingInDialog/AnimationPlayer.play("animate")


# ------------------------------------------------------------------------------
func display_logged_in_dialog(user_name : String, identity_id : int) -> void:
	$LoggingInDialog.hide()
	$LoggedInDialog.show()
	$LoggedInDialog/CurrentUser/Name.text = user_name
	$LoggedInDialog/LinkWalletLabel.visible = identity_id == -1
	$LoggedInDialog/WalletLinkedLabel.visible = false
	$LoggedInDialog/PlayButton.disabled = identity_id == -1
	Network.notify_of_login(Enjin.get_current_user_id(), identity_id)
	
	
# ------------------------------------------------------------------------------
func display_wallet_linked():
	$LoggedInDialog/LinkWalletLabel.visible = false
	$LoggedInDialog/WalletLinkedLabel.visible = true
	$LoggedInDialog/PlayButton.disabled = false
	
	
# ------------------------------------------------------------------------------
func _on_LogoutButton_pressed():
	Enjin.logout()
	$LoggedInDialog.hide()
	$LoginDialog.show()
	
	_email_field.grab_focus()
	_email_field.text = ""
	_password_field.text = ""
	_error_label.text = ""

	emit_signal("user_logged_out")
	

# ------------------------------------------------------------------------------
