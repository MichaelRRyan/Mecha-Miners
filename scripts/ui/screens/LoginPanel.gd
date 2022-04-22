extends Control

onready var _emailField : LineEdit = find_node("EmailField")
onready var _passwordField : LineEdit = find_node("PasswordField")
onready var _error_label : Label = find_node("ErrorLabel")


# ------------------------------------------------------------------------------
func _ready():
	var _r = Enjin.connect("login_response", self, "_on_Enjin_login_response")


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
	
	
# ------------------------------------------------------------------------------
func _display_error_message(message : String) -> void:
	if _error_label:
		_error_label.text = message


# ------------------------------------------------------------------------------

