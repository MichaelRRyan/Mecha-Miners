extends TextureButton

var stack = null

# -----------------------------------------------------------------------------
func set_item_stack(item_stack):
	if item_stack:
		stack = item_stack
		var data = ItemData.data[item_stack.type]
		$ItemTexture.texture.region = data.texture_region
		$ItemTexture.texture.margin = data.texture_margin
		$QuantityLabel.text = str(item_stack.quantity)
	else:
		stack = null
		$ItemTexture.texture.region = Rect2()
		$QuantityLabel.text = ""


# -----------------------------------------------------------------------------
func get_item_stack():
	return stack


# -----------------------------------------------------------------------------
func _ready():
	$ItemTexture.texture = $ItemTexture.texture.duplicate()
	set_item_stack(null)


# -----------------------------------------------------------------------------
