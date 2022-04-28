extends Control

onready var _name_label = find_node("NameLabel")
onready var _elixirite_quantity_label = find_node("QuantityLabel")

# ------------------------------------------------------------------------------
func _ready():
	var user_name =  Enjin.get_current_user_name()
	if not user_name.empty():
		_name_label.text = user_name
		
	Network.connect_to_server()
	
	if Enjin.get_current_user_id() != -1:
		var _r = Enjin.connect("request_token_balance_response", self, 
			"_on_Enjin_request_token_balance_response")
		
		Enjin.request_token_balance(Enjin.get_current_wallet_address(), Enjin.ELIXIRITE_ID)


# ------------------------------------------------------------------------------
func _on_NavigateButton_pressed():
	if get_tree().change_scene("res://scenes/world/World.tscn") != OK:
		print("Error changing to World.")
	

# ------------------------------------------------------------------------------
func _on_ShopButton_pressed():
	if get_tree().change_scene("res://scenes/ui/screens/ShopScreen.tscn") != OK:
		print("Error changing to ShopScreen.")


# ------------------------------------------------------------------------------
func _on_EquipmentButton_pressed():
	pass # Replace with function body.

	
# ------------------------------------------------------------------------------
func _on_ExitButton_pressed():
	if get_tree().change_scene("res://scenes/ui/screens/TitleScreen.tscn") != OK:
		print("Error changing to TitleScreen.")

	
# ------------------------------------------------------------------------------
func _on_NavigateButton_focus_entered():
	pass # Replace with function body.
	
	
# ------------------------------------------------------------------------------
func _on_ShopButton_focus_entered():
	pass # Replace with function body.


# ------------------------------------------------------------------------------
func _on_EquipmentButton_focus_entered():
	pass # Replace with function body.


# ------------------------------------------------------------------------------
func _on_ExitButton_focus_entered():
	pass # Replace with function body.


# ------------------------------------------------------------------------------
func _on_Enjin_request_token_balance_response(data, _errors) -> void:
	if data != null:
		_elixirite_quantity_label.text = str(data.value)
	else:
		_elixirite_quantity_label.text = str(0)

# ------------------------------------------------------------------------------
