extends Control

onready var _elixirite_quantity_label = find_node("QuantityLabel")


# ------------------------------------------------------------------------------
func _ready():
	if Enjin.get_current_user_id() != -1:
		var _r = Enjin.connect("request_token_balance_response", self, 
			"_on_Enjin_request_token_balance_response")
		
		Enjin.request_token_balance(Enjin.get_current_wallet_address(), Enjin.ELIXIRITE_ID)
	
	
# ------------------------------------------------------------------------------
func _on_MintButton_pressed():
	var wallet_address = Enjin.get_current_wallet_address()
	
	if not wallet_address.empty():
		Network.mint_tokens(wallet_address)
	
	
# ------------------------------------------------------------------------------
func _on_SentButton_pressed():
	var identity_id = Enjin.get_current_identity_id()
	var wallet_address = Enjin.MECHA_MINERS_WALLET
	
	if identity_id != -1:
		Enjin.send_tokens(identity_id, Enjin.APP_ID, Enjin.ELIXIRITE_ID, wallet_address, 1)


# ------------------------------------------------------------------------------
func _on_BackButton_pressed():
	if get_tree().change_scene("res://scenes/ui/screens/ShipScreen.tscn") != OK:
		print("Error changing to ShipScreen.")


# ------------------------------------------------------------------------------
func _on_Enjin_request_token_balance_response(data, _errors) -> void:
	if data != null:
		_elixirite_quantity_label.text = str(data.value)
	else:
		_elixirite_quantity_label.text = str(0)
	
	$BalanceTimer.start()


# ------------------------------------------------------------------------------
func _on_BalanceTimer_timeout():
	Enjin.request_token_balance(Enjin.get_current_wallet_address(), Enjin.ELIXIRITE_ID)


# ------------------------------------------------------------------------------
