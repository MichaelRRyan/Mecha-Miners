extends CanvasLayer


func _on_Player_crystal_amount_changed(total_crystals):
	$CrystalsAmount/Amount.text = str(total_crystals)
