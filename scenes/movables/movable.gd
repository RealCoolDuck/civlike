class_name Movable
extends Occupant

var map: HexMap
var movable_definition: MovableDefinition

var sprite_2d: Sprite2D
signal end_move

func _init(game_map: HexMap, definition: MovableDefinition):
	map = game_map
	movable_definition = definition

func _ready():
	sprite_2d = Sprite2D.new()
	add_child(sprite_2d)
	sprite_2d.texture = movable_definition.texture

func set_coords(coords: Vector2i):
	map_position = coords

func get_walkable_tiles() -> Array[Vector2i]:
	var start := map_position
	var start_tile := map.get_tile(start)
	if not start_tile.walkable:
		return []
	
	var visited = {start: null}
	var fringes = [[start]]
	
	for k in range(1, movable_definition.range+1):
		fringes.append([])
		for hex in fringes[k-1]:
			for dir in map.DIRECTIONS:
				var neighbour = hex + dir
				if map.tile_contains_movable(neighbour):
					continue
				var neighbour_tile := map.get_tile(neighbour)
				if neighbour not in visited and neighbour_tile.walkable:
					visited[neighbour] = null
					fringes[k].append(neighbour)
	return visited.keys()

func can_move_to(end: Vector2i) -> bool:
	if end in get_walkable_tiles() and end != map_position:
		return true
	return false

func get_hex_path(start: Vector2i, end: Vector2i) -> Array[Vector2i]:
	var came_from := {start: null}
	var queue: Array[Vector2i] = [start]
	var current: Vector2i
	
	while not queue.is_empty():
		current = queue.pop_front()
		if current == end:
			break
		for dir in map.DIRECTIONS:
			var neighbour := current + dir
			if neighbour in came_from:
				continue
			var tile := map.get_tile(neighbour)
			if not tile.walkable:
				continue
			came_from[neighbour] = current
			queue.append(neighbour)
			
	if end not in came_from:
		return []
	
	var path: Array[Vector2i] = []
	current = end
	while came_from[current] != null:
		path.push_front(current)
		current = came_from[current]
	return path

func move_to(coords: Vector2i):
	z_index = 10
	var path = get_hex_path(map_position, coords)
	for hexes in path:
		print(hexes)
		var target_position = map.tile_to_world(hexes)

		var tween := create_tween()
		tween.tween_property(
			self,
			"global_position",
			target_position,
			0.2
		)

		await tween.finished

	map_position = coords
	end_move.emit()
