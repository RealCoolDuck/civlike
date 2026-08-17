class_name Movable
extends Occupant

var map: HexMap
var movable_definition: MovableDefinition: 
	set(new):
		movable_definition = new
		if not sprite_2d:
			await ready
		sprite_2d.texture = movable_definition.texture

var units: Dictionary[Enums.UnitType, int] = {}

var sprite_2d: Sprite2D
signal end_move

func _init(game_map: HexMap, definition: MovableDefinition):
	map = game_map
	movable_definition = definition

func _ready():
	sprite_2d = Sprite2D.new()
	add_child(sprite_2d)

func set_coords(coords: Vector2i):
	map_position = coords

func get_movable_tiles() -> Array[Vector2i]:
	if movable_definition.walks:
		return get_walkable_tiles()
	elif movable_definition.swims:
		return get_swimmable_tiles()
	return []

func get_swimmable_tiles() -> Array[Vector2i]:
	var start := map_position
	var start_tile := map.get_tile(start)
	if not start_tile.swimmable:
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
				if neighbour not in visited and neighbour_tile.swimmable:
					visited[neighbour] = null
					fringes[k].append(neighbour)
	
	# Add adjacent land tiles for disembarkation
	for dir in map.DIRECTIONS:
		var neighbour = start + dir

		if neighbour in visited:
			continue

		var neighbour_tile := map.get_tile(neighbour)

		if neighbour_tile.walkable:
			visited[neighbour] = null
	
	return visited.keys()

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
	
	# Add adjacent water tiles for embarkation
	for dir in map.DIRECTIONS:
		var neighbour = start + dir

		if neighbour in visited:
			continue

		var neighbour_tile := map.get_tile(neighbour)

		if neighbour_tile.swimmable:
			visited[neighbour] = null
	
	return visited.keys()

func can_move_to(end: Vector2i) -> bool:
	var movable_tiles := get_movable_tiles() as Array
	if end in movable_tiles and end != map_position:
			return true
	return false

func get_hex_path(start: Vector2i, end: Vector2i) -> Array[Vector2i]:
	if movable_definition.walks:
		return get_walkable_hex_path(start, end)
	elif movable_definition.swims:
		return get_swimmable_hex_path(start, end)
	return []

func get_swimmable_hex_path(start: Vector2i, end: Vector2i) -> Array[Vector2i]:
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
			if tile.swimmable:
				came_from[neighbour] = current
				queue.append(neighbour)
			
			# Embark directly from the starting tile
			elif tile.walkable and current == start and neighbour == end:
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

func get_walkable_hex_path(start: Vector2i, end: Vector2i) -> Array[Vector2i]:
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
			if tile.walkable:
				came_from[neighbour] = current
				queue.append(neighbour)
			
			# Embark directly from the starting tile
			elif tile.swimmable and current == start and neighbour == end:
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
