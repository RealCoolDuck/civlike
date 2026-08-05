extends Resource
class_name HexTileDefinition

enum TerrainType {
	RED,
	BLUE
}

@export var terrain: TerrainType = TerrainType.RED
@export var atlas_coords: Vector2i = Vector2i.ZERO
@export var generation_weight: float = 1.0
