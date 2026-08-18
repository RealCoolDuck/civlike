class_name BorderOverlay
extends TileMapLayer

var modulated_cells: Dictionary = {}
const WHITE_CELL_ATLAS_COORDS := Vector2i(0, 1)
const TILE_ATLAS_SOURCE_ID := 0


func modulate_cell(coords: Vector2i, color: Color):
	set_cell(coords, TILE_ATLAS_SOURCE_ID, WHITE_CELL_ATLAS_COORDS)	
	modulated_cells[coords] = color
	notify_runtime_tile_data_update()


func _use_tile_data_runtime_update(coords: Vector2i) -> bool:
	return modulated_cells.has(coords)

func _tile_data_runtime_update(coords: Vector2i, tile_data: TileData) -> void:
	tile_data.modulate = modulated_cells.get(coords, Color.WHITE)
