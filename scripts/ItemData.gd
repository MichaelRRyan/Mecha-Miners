extends Node

enum ItemType {
	NULL = -1,
	GEM = 0,
}

var data = {
	ItemType.GEM: {
		texture_region = Rect2(144, 80, 16, 16),
		texture_margin = Rect2(0.5, 0.5, 0, 0),
		max_quantity = 80,
	}
}


# ------------------------------------------------------------------------------
func get_data(item_type):
	return data[item_type]


# ------------------------------------------------------------------------------
