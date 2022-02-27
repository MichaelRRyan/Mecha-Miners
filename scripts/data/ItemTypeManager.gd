extends Node

var item_types : Array = [] # Of type ItemType


#-------------------------------------------------------------------------------
# Doesn't do any bounds checks, can throw an error if not careful.
func get_item_type(id : int) -> ItemType:
	return item_types[id]


# ------------------------------------------------------------------------------
func get_item_type_by_name(name : String) -> ItemType:
	for type in item_types:
		if type.name == name:
			return type
	return null


# ------------------------------------------------------------------------------
func get_item_index_by_name(name : String) -> int:
	for i in item_types.size():
		if item_types[i].name == name:
			return i
	return -1


#-------------------------------------------------------------------------------
func _ready() -> void:
	var gem = ItemType.new()
	gem.name = "Gem"
	gem.category = Item.Category.GEM
	gem.max_stack = 80
	gem.texture = Rect2(144, 80, 16, 16)
	gem.texture_margin = Rect2(0.5, 0.5, 0, 0)
	item_types.append(gem)
	

#-------------------------------------------------------------------------------
