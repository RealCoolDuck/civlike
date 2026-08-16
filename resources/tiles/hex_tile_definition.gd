extends Resource
class_name HexTileDefinition

enum TerrainType {
	EMPTY,
	RED,
	BLUE
}

@export var terrain: TerrainType = TerrainType.EMPTY
@export var atlas_coords: Vector2i = Vector2i.ZERO
@export var generation_weight: float = 1.0
@export var walkable: bool = false
@export var swimmable: bool = false
