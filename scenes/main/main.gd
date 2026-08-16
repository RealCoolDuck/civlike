extends Node2D

@onready var map: HexMap = $HexMap
@onready var hex_borders: HexBorders = $HexBorders
@onready var camera: MapCamera = $Camera2D
@onready var pick_color_view = $CanvasLayer/PickColor

@onready var info_label = $CanvasLayer/InfoLabel

@onready var structure_buttons = $CanvasLayer/StructureButtons

@onready var fog: ColorRect = $Fog
@onready var structure_info: StructureInfo = $CanvasLayer/StructureInfo
@onready var build_panel: Control = $CanvasLayer/BuildPanel

@onready var enter_structure_name = $CanvasLayer/EnterStructureName

@export var structure_definitions: Array[StructureDefinition] = []
@export var rings: int = 30

var spawn_border: Border = Border.new()
var spawn_structure: Structure

var selected_structure: Structure = null

var rng = RandomNumberGenerator.new()
signal colour_selected

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("select"):
		map.on_select_pressed()
	if event.is_action_pressed("add_troop"):
		var coords := map.get_mouse_coords()
		if map.get_tile(coords).walkable:
			map.add_movable(map.movables_definitions[0], coords)

func _ready():
	start_game()

func start_game():
	generate_map()
	pick_colour()
	prepare_camera()
	await colour_selected
	pick_spawn()

func generate_map():
	map.create_hexagon_map(rings)

func pick_colour():
	pick_color_view.visible = true
	GameState.players.append(PlayerData.new())
	map.block = true

func add_ring(border: Border, radius: int):
	var coords := map.DIRECTIONS[4] * radius
	for i in range(6):
		for _i in range(radius):
			coords += map.DIRECTIONS[i]
			border.add_hex(coords)

func prepare_camera():
	camera.global_position = map.tile_to_world(Vector2i.ZERO)
	camera.zoom = Vector2i.ONE * 0.4
	
	camera.block_input = true
	var width: int = int(26* rings)
	var height: int = int((26 * (3 * rings + 2))/4)
	
	camera.limit_left = -width + 12
	camera.limit_right = width + 12
	camera.limit_top = -height + 6
	camera.limit_bottom = height - 7
	
	fog.size.x = width * 2
	fog.size.y = height * 2
	fog.global_position = Vector2(-width+13, -height+13)
	
	

func pick_spawn():
	info_label.visible = true
	info_label.text = "Pick your spawn"
	spawn_border.color = Color.RED
	
	spawn_border.add_hex(Vector2i.ZERO)

	for i in range(1,6):
		add_ring(spawn_border, i)
	
	hex_borders.draw_border(spawn_border)
	map.hex_selected.connect(_on_hex_spawn_selected)


func _on_hex_spawn_selected(coords: Vector2i):
	if not coords in spawn_border.contents or not map.get_tile(coords).walkable:
		hex_borders.draw_border(spawn_border)
		return
	spawn_structure = map.add_structure(structure_definitions[0], coords, true)
	spawn_structure.border.color = GameState.players[0].color
	camera.block_input = false
	hex_borders.clear_borders()
	map.hex_selected.disconnect(_on_hex_spawn_selected)
	
	selected_structure = spawn_structure
	enter_structure_name.visible = true
	map.block = true
	
	map.hex_selected.connect(_on_hex_selected)
	info_label.visible = false
	structure_buttons.visible = true

func _on_hex_selected(coords: Vector2i):
	var set_info_visible: bool = false
	if coords in map.occupants:
		for occupant in map.occupants[coords]:
			if occupant is Structure:
				structure_buttons.visible = true
				set_info_visible = true
				selected_structure = occupant
				return
	
	if not set_info_visible:
		structure_buttons.visible = false

func _on_pick_color_color_picked(color: Color) -> void:
	GameState.players[0].color = color
	pick_color_view.visible = false
	map.block = false
	colour_selected.emit()

func _on_info_button_pressed() -> void:
	if selected_structure:
		structure_info.visible = true
		structure_info.set_structure(selected_structure)
		map.block = true

func _on_structure_info_exit() -> void:
	map.block = false

func _on_enter_structure_name_name_submitted(name: String) -> void:
	map.block = false
	selected_structure.structure_name = name
	structure_info.set_structure(selected_structure)

func _on_structure_info_edit_structure_title(structure: Structure) -> void:
	enter_structure_name.visible = true
	map.block = true

func _on_build_button_pressed() -> void:
	if selected_structure:
		build_panel.visible = true


func _structure_upgade_pressed() -> void:
	selected_structure.upgrade_structure()
