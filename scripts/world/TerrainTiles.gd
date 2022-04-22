tool
extends TileSet
class_name Tile

enum Type {
	EMPTY = -1,
	STONE = 0,
	UNBREAKABLE = 1,
	CRYSTAL = 2,
	BACKGROUND = 6,
}

var binds = {
	Type.STONE: [ Type.UNBREAKABLE, Type.CRYSTAL ],
	Type.UNBREAKABLE: [ Type.CRYSTAL, Type.STONE ],
	Type.CRYSTAL: [ Type.STONE, Type.UNBREAKABLE ],
}


# -----------------------------------------------------------------------------
func _is_tile_bound(drawn_id, neighbor_id):
	if drawn_id in binds:
		return neighbor_id in binds[drawn_id]
	return false


# -----------------------------------------------------------------------------
