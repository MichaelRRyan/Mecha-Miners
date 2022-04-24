extends Control


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
