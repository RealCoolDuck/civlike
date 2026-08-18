class_name MapCamera
extends Camera2D

@export var pan_speed := 1.0
@export var zoom_speed := 0.5
@export var zoom_speed_trackpad := 0.01
@export var min_zoom := 0.2
@export var max_zoom := 3.0

@export var map: HexMap

var dragging := false
var zoom_in := false
var zoom_out := false

var block_input: bool = false

var last_mouse_position := Vector2.ZERO

var move_direction: Vector2 = Vector2.ZERO

func _unhandled_input(event: InputEvent) -> void:
	if block_input:
		return
	# Start dragging
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			dragging = event.pressed
			last_mouse_position = event.position
			
	if event.is_action_pressed("zoom_in"):
		zoom_in = true
	elif event.is_action_released("zoom_in"):
		zoom_in = false

	if event.is_action_pressed("zoom_out"):
		zoom_out = true
	elif event.is_action_released("zoom_out"):
		zoom_out = false
	
	if event.is_action_pressed("up"):
		move_direction.y = -1
	if event.is_action_pressed("down"):
		move_direction.y = 1
	if event.is_action_pressed("left"):
		move_direction.x = -1
	if event.is_action_pressed("right"):
		move_direction.x = 1
	
	if event.is_action_released("up"):
		move_direction.y = 0
	if event.is_action_released("down"):
		move_direction.y = 0
	if event.is_action_released("left"):
		move_direction.x = 0
	if event.is_action_released("right"):
		move_direction.x = 0

	# Move camera while dragging
	if event is InputEventMouseMotion and dragging:
		var mouse_delta = event.position - last_mouse_position
		position -= mouse_delta * pan_speed / zoom.x
		position = Vector2(clamp(position.x,limit_left+get_viewport_rect().size.x/2,limit_right-get_viewport_rect().size.x/2),clamp(position.y,limit_top+get_viewport_rect().size.y/2,limit_bottom-get_viewport_rect().size.y/2))
		last_mouse_position = event.position
	
	if event is InputEventPanGesture:
		zoom_camera(-zoom_speed_trackpad * event.delta.y)

func _process(delta: float) -> void:
	if zoom_in:
		zoom_camera(zoom_speed * delta)
	if zoom_out:
		zoom_camera(-zoom_speed * delta)
	
	position += move_direction * pan_speed / zoom.x
	
	map.update_border_camera(global_position, zoom)
		
func zoom_camera(amount: float):
	var new_zoom := zoom + Vector2(amount, amount)
	
	new_zoom.x = clamp(new_zoom.x, min_zoom, max_zoom)
	new_zoom.y = clamp(new_zoom.y, min_zoom, max_zoom)

	var mouse_pos := get_global_mouse_position()
	zoom = new_zoom
	var new_mouse_pos := get_global_mouse_position()
	position +=  (mouse_pos - new_mouse_pos)
