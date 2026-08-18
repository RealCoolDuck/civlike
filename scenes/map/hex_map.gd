class_name HexMap
extends Node2D

@onready var tile_map_layer: TileMapLayer = $Terrain
@onready var hover_tile: HoverTile = $HoverTile
@onready var border_camera: Camera2D = $BorderOverlay/SubViewportContainer/SubViewport/BorderCamera
@onready var border_overlays: BorderOverlay = $BorderOverlay/SubViewportContainer/SubViewport/Borders
@onready var border_overlay_container: SubViewportContainer = $BorderOverlay/SubViewportContainer

@export var height_noise: FastNoiseLite
@export var tiles: Array[HexTileDefinition] = []
@export var movables_definitions: Array[MovableDefinition] = []
@export var ocean_level := 0.0
@export var bob_tile_height := 2.0
@export var hex_borders: HexBorders

var rng = RandomNumberGenerator.new()
var highlight_scene := preload("res://scenes/map/highlight/highlight.tscn")


const TILE_ATLAS_SOURCE_ID := 0
const EMPTY_ATLAS_COORDS := Vector2i(0, 0)
const HEX_COORDS_INF = Vector2i(10000, 10000)
const DARK_ATLAS_COORDS := Vector2i(1, 1)


const HEX_WIDTH_PX: int = 26
const HEX_HEIGHT_PX: int = 24

var highlighted_cells: Dictionary[Vector2i, Occupant] = {}
var occupants: Dictionary[Vector2i, Array] = {}

var carried_occupants: Array[Occupant] = [] # for when a movable is on the hovered tile
var selected_movable: Movable = null
var selected_structure: Structure = null


var upgrading_structure: bool = false
var tile_hovered: bool = false
var block: bool = false

signal hex_selected(coords: Vector2i)

const DIRECTIONS: Array[Vector2i] = [
	Vector2i(1, 0),
	Vector2i(1, -1),
	Vector2i(0, -1),
	Vector2i(-1, 0),
	Vector2i(-1, 1),
	Vector2i(0, 1)
]

func _ready() -> void:
	height_noise.seed = rng.randi()

func _process(_delta: float):
	if block:
		return
	var mouse_coords := get_mouse_coords()
	if hover_tile.hex_coords != mouse_coords:
		if tile_hovered:
			set_cell(hover_tile.hex_coords, hover_tile.atlas_coords)
		hover_cell(mouse_coords)
		tile_hovered = true

func show_border_overlay():
	border_overlay_container.visible = true

func hide_border_overlay():
	border_overlay_container.visible = false

func set_border_overlay(coords: Vector2i, color: Color):
	border_overlays.modulate_cell(coords, color)

func add_movable(definition: MovableDefinition, coords: Vector2i) -> Movable:
	if coords in occupants:
		push_warning("Tiles should not contain multiple occupants!")
	var movable = Movable.new(self, definition)
	movable.set_coords(coords)
	if not coords in occupants:
		occupants[coords] = []
	occupants[coords].append(movable)
	add_child(movable)
	
	if hide_hover_tile:
		hide_hover_tile()
	
	movable.global_position = tile_to_world(coords)
	return movable

func highlight_cells(coords: Array[Vector2i]):
	for coord in coords:
		highlight_cell(coord)

func add_unit(type: Enums.UnitType, coords: Vector2i):
	var movable: Movable = null
	if coords in occupants:
		for occupant in occupants[coords]:
			if occupant is Movable:
				movable = occupant
				break
	if not movable:
		movable = add_movable(movables_definitions[0], coords)
	
	if type in movable.units:
		movable.units[type] += 1
	else:
		movable.units[type] = 1
		
	GameState.selected_movable = movable
	

func add_structure(definition: StructureDefinition, coords: Vector2i, hide_hover_tile: bool = false) -> Structure:
	if coords in occupants:
		push_warning("Tiles should not contain multiple occupants!")
	var structure = Structure.new(self, definition, coords)
	structure.z_index = 10
	if coords not in occupants:
		occupants[coords] = []
	occupants[coords].append(structure)
	add_child(structure)
	structure.global_position = tile_to_world(coords)
	if hide_hover_tile:
		hide_hover_tile()
	
	return structure

func get_mouse_coords() -> Vector2i:
	return tile_map_layer.local_to_map(get_global_mouse_position() / scale.x)

func hover_cell(coords: Vector2i):
	drop_carried_occupants()
	
	var atlas_coords := tile_map_layer.get_cell_atlas_coords(coords)
	hover_tile.hex_coords = coords
	hover_tile.set_atlas_position(atlas_coords)
	hover_tile.global_position = tile_to_world(coords)
	hover_tile.reset_bob(bob_tile_height)
	
	tile_map_layer.set_cell(
		coords,
		0,
		EMPTY_ATLAS_COORDS)
	
	if coords in occupants:
		for occupant in occupants[coords]:
			occupant.reparent(hover_tile, true)
			carried_occupants.append(occupant)

func add_occupant(occupant: Occupant):
	var coords := occupant.map_position
	if not coords in occupants:
		occupants[coords] = []
	occupants[coords].append(occupant)

func remove_occupant(occupant: Occupant):
	var coords := occupant.map_position
	carried_occupants.erase(occupant)
	
	if coords not in occupants:
		return
	occupants[coords].erase(occupant)
	if occupants[coords].is_empty():
		occupants.erase(coords)

func drop_carried_occupants():
	for occupant in carried_occupants:
		occupant.reparent(self)
		var coords := occupant.map_position
		occupant.global_position = tile_to_world(coords)
	carried_occupants = []

func create_hexagon_map(radius: int):
	set_cell(Vector2i.ZERO)
	border_overlays.set_cell(Vector2i.ZERO, TILE_ATLAS_SOURCE_ID, DARK_ATLAS_COORDS)
	for i in range(1, radius + 1):
		create_ring(i)

func create_ring(radius: int):
	var coords := DIRECTIONS[4] * radius
	for i in range(6):
		for _i in range(radius):
			coords += DIRECTIONS[i]
			set_cell(coords)
			border_overlays.set_cell(coords, TILE_ATLAS_SOURCE_ID, DARK_ATLAS_COORDS)

func set_cell(coords: Vector2i, atlas_coords := get_tile(coords).atlas_coords):
	tile_map_layer.set_cell(coords, TILE_ATLAS_SOURCE_ID, atlas_coords)

func get_tile(coords: Vector2i) -> HexTileDefinition:
	var height = height_noise.get_noise_2d(coords.x, coords.y)
	if height < ocean_level:
		return tiles[1]
	elif height < ocean_level + 0.3:
		return tiles[0]
	else:
		return tiles[2]

func highlight_cell(coords: Vector2i):
	if coords in highlighted_cells:
		return
	
	var scene: Occupant = highlight_scene.instantiate()
	highlighted_cells[coords] = scene
	add_child(scene)
	scene.map_position = coords
	scene.global_position = tile_to_world(coords)
	if not coords in occupants:
		occupants[coords] = []
	occupants[coords].append(scene)

func clear_highlights():
	for coords in highlighted_cells:
		var scene := highlighted_cells[coords]
		remove_occupant(scene)
		scene.queue_free()
	
	highlighted_cells = {}

func tile_to_world(coords: Vector2i):
	return tile_map_layer.to_global(
		tile_map_layer.map_to_local(coords))

func on_select_pressed():
	if block:
		return
	
	var coords := get_mouse_coords()
	
	clear_highlights()
	hex_borders.clear_borders()
	
	hex_selected.emit(coords)
	
	if upgrading_structure:
		return
	if selected_structure:
		selected_structure.deselect()
	if selected_movable:
		var movable := selected_movable
		if movable.can_move_to(coords):
			_on_blocking_action_start()
			occupants[movable.map_position].erase(movable)
			if coords not in occupants:
				occupants[coords] = []
			occupants[coords].append(movable)
			movable.move_to(coords)
			if movable.movable_definition.walks and get_tile(coords).swimmable:
				movable.movable_definition = movables_definitions[1]
			elif movable.movable_definition.swims and get_tile(coords).walkable:
				movable.movable_definition = movables_definitions[0]
			movable.end_move.connect(_on_blocking_action_end)
		selected_movable = null
	elif coords in occupants:
		for occupant in occupants[coords]:
			if occupant is Movable:
				select_movable(occupant, coords)
			elif occupant is Structure:
				occupant.select()
				selected_structure = occupant
	else:
		selected_movable = null
		if selected_structure:
			selected_structure.deselect()
			selected_structure = null

func select_movable(movable: Movable, coords: Vector2i):
	selected_movable = movable
	var walkable_tiles = movable.get_movable_tiles()
	for tile in walkable_tiles:
		if tile == coords:
			continue
		highlight_cell(tile)

func tile_contains_movable(coords: Vector2i) -> bool:
	if coords not in occupants:
		return false
	for occupant in occupants[coords]:
		if occupant is Movable:
			return true
	return false

func _on_blocking_action_start():
	hide_hover_tile()
	block = true

func hide_hover_tile():
	drop_carried_occupants()
	if tile_hovered:
		set_cell(hover_tile.hex_coords, hover_tile.atlas_coords)
	tile_hovered = false
	hover_tile.set_atlas_position(Vector2i.ZERO)
	hover_tile.hex_coords = HEX_COORDS_INF

func _on_blocking_action_end():
	block = false

func update_border_camera(global_position: Vector2, zoom: Vector2):
	border_camera.global_position = global_position
	border_camera.zoom = zoom
