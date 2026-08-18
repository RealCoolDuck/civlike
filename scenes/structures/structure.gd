class_name Structure
extends Occupant

var map: HexMap
var definition: StructureDefinition

var sprite_2d: Sprite2D
var label: StructureLabel

var border: Border = Border.new()

var structure_name: String = "":
	set(value):
		structure_name = value
		label.set_structure_name(value)

var population: int:
	set(value):
		population = value
		label.set_population(value)

var money: int:
	set(value):
		money = value
		label.set_coins(value)

var upgrade_counter: int = 0

var label_scene = preload("res://scenes/structures/structure_label.tscn")

func _init(game_map: HexMap, my_definition: StructureDefinition, coords):
	map = game_map
	definition = my_definition
	map_position = coords

func _ready() -> void:
	sprite_2d = Sprite2D.new()
	label = label_scene.instantiate()
	add_child(label)
	add_child(sprite_2d)
	sprite_2d.texture = definition.texture
	label.position.y -= sprite_2d.get_rect().size.y / 2 + 6
	border.add_hex(map_position)
	money = definition.starting_money
	population = definition.starting_population
	border.color_updated.connect(_on_border_color_update)

func _on_border_color_update(color: Color):
	label.set_structure_name_color(color)

func upgrade_structure():
	upgrade_counter = 6
	map.hex_selected.connect(_on_upgrade_location_selected)
	highlight_upgradable_tiles()
	map.upgrading_structure = true
	draw_border()

func highlight_upgradable_tiles():
	var highlighted: Array[Vector2i] = []
	
	for hex in border.contents:
		for dir in map.DIRECTIONS:
			var new_coords := hex + dir
			if new_coords in border.contents or new_coords in highlighted:
				continue
			map.highlight_cell(new_coords)

func draw_border():
	map.hide_hover_tile()
	map.hex_borders.draw_all_player_borders()

func select():
	draw_border()
	label.visible = true

func deselect():
	label.visible = false

func _on_upgrade_location_selected(coords: Vector2i):
	if coords in border.contents:
		highlight_upgradable_tiles()
		draw_border()
		return
	var valid: bool = false
	for dir in map.DIRECTIONS:
		if coords + dir in border.contents:
			valid = true
	if not valid:
		highlight_upgradable_tiles()
		draw_border()
		return
	upgrade_counter -= 1
	
	border.add_hex(coords)
	
	if upgrade_counter <= 0:
		map.hex_selected.disconnect(_on_upgrade_location_selected)
		map.upgrading_structure = false
		map.clear_highlights()
		draw_border()
		return
	highlight_upgradable_tiles()
	draw_border()
