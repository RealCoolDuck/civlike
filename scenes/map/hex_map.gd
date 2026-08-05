class_name HexMap
extends Node

@onready var tile_map_layer: TileMapLayer = $TileMapLayer

@export var height_noise: Noise
@export var tiles: Array[HexTileDefinition] = []
@export var rings := 300
@export var ocean_level := 0.0

const TILE_ATLAS_SOURCE_ID := 1

const DIRECTIONS: Array[Vector2i] = [
	Vector2i(0, 1),
	Vector2i(-1, 0),
	Vector2i(-1, -1),
	Vector2i(0, -1),
	Vector2i(1, 0),
	Vector2i(1, 1)
]

func _ready() -> void:
	create_hexagon_map(rings)

func create_hexagon_map(radius: int):
	add_cell(Vector2i.ZERO)
	for i in range(1, radius):
		create_ring(i)

func create_ring(radius: int):
	var coords := DIRECTIONS[4] * radius
	for i in range(6):
		for _i in range(radius):
			coords += DIRECTIONS[i]
			add_cell(coords)

func add_cell(coords: Vector2i):
	var height := get_height(coords)
	var definition := get_tile_from_height(height)

	tile_map_layer.set_cell(
		coords,
		TILE_ATLAS_SOURCE_ID,
		definition.atlas_coords
	)

func get_height(coords: Vector2i) -> float:
	# Scale controls the size of terrain features
	var scale := 0.1
	
	return height_noise.get_noise_2d(
		coords.x * scale,
		coords.y * scale
	)

func get_tile_from_height(height: float) -> HexTileDefinition:
	if height < ocean_level:
		return tiles[1] # ocean
	
	return tiles[0] # grass
