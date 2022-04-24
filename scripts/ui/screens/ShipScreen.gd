extends Control

onready var _name_label = find_node("NameLabel")

# ------------------------------------------------------------------------------
func _ready():
	var user_name =  Enjin.get_current_user_name()
	if not user_name.empty():
		_name_label.text = user_name


# ------------------------------------------------------------------------------
func _on_NavigateButton_pressed():
	if get_tree().change_scene("res://scenes/ui/screens/PlanetNavigationScreen.tscn") != OK:
		print("Error changing from ShipScreen to PlanetNavigationScreen.")
	

# ------------------------------------------------------------------------------
func _on_ShopButton_pressed():
	pass # Replace with function body.


# ------------------------------------------------------------------------------
func _on_EquipmentButton_pressed():
	pass # Replace with function body.

	
# ------------------------------------------------------------------------------
