class_name HexTile
extends Node

var q: int
var r: int

const DIRECTIONS = [
	Vector2i(1, 0),
	Vector2i(1, -1),
	Vector2i(0, -1),
	Vector2i(-1, 0),
	Vector2i(-1, 1),
	Vector2i(0, 1)
]

enum terrain_type {
	OCEAN,
	GRASS
}
