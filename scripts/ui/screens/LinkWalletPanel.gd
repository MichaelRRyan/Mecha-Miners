extends Control

signal wallet_linked_successfully()

onready var _error_label : Label = find_node("ErrorLabel")


# ------------------------------------------------------------------------------
func _ready() -> void:
	var _r = Network.connect("create_identity_response", self, "_on_Network_create_identity_response")
	
# ------------------------------------------------------------------------------
func _on_LinkButton_pressed() -> void:
	var eth_address = $LinkWalletDialog/WalletAddressField.text
	if not eth_address.empty():
		display_linking_dialog()
		Network.request_identity(Enjin.get_current_user_id(), eth_address)
	else:
		_display_error_message("Wallet address field cannot be empty.")


# ------------------------------------------------------------------------------
func _on_Network_create_identity_response(identity_id):
	if identity_id == -1:
		_display_error_message("Not a valid wallet address.")
		
	else:
		_hide_all()
		$AlreadyLinkedDialog.show()
		emit_signal("wallet_linked_successfully")
		

# ------------------------------------------------------------------------------
func _display_error_message(message : String) -> void:
	if _error_label:
		_error_label.text = message
	
		
# ------------------------------------------------------------------------------
func display_login_dialog() -> void:
	_hide_all()
	$PleaseLoginDialog.show()


# ------------------------------------------------------------------------------
func display_already_linked_dialog() -> void:
	_hide_all()
	$AlreadyLinkedDialog.show()


# ------------------------------------------------------------------------------
func display_linking_dialog() -> void:
	_hide_all()
	$LinkingDialog.show()
	$LinkingDialog/AnimationPlayer.play("animate")
	
	
# ------------------------------------------------------------------------------
func display_connect_wallet_dialog(user_name : String) -> void:
	_hide_all()
	$LinkWalletDialog.show()
	$LinkWalletDialog/CurrentUser/Name.text = user_name
	$LinkWalletDialog/WalletAddressField.text = ""
	$LinkWalletDialog/WalletAddressField.grab_focus()


# ------------------------------------------------------------------------------
func _hide_all():
	$PleaseLoginDialog.hide()
	$AlreadyLinkedDialog.hide()
	$LinkWalletDialog.hide()
	$LinkingDialog.hide()
	$LinkingDialog/AnimationPlayer.stop()


# ------------------------------------------------------------------------------
func _on_WalletAddressField_text_entered(_new_text):
	_on_LinkButton_pressed()
	$LinkWalletDialog/LinkButton.grab_focus()


# ------------------------------------------------------------------------------
