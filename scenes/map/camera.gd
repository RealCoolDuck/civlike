class_name MapCamera
extends Camera2D

@export var pan_speed := 1.0
@export var zoom_speed := 0.5
@export var min_zoom := 0.05
@export var max_zoom := 3.0

var dragging := false
var zoom_in := false
var zoom_out := false

var last_mouse_position := Vector2.ZERO

func _unhandled_input(event: InputEvent) -> void:
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

	# Move camera while dragging
	if event is InputEventMouseMotion and dragging:
		var mouse_delta = event.position - last_mouse_position
		position -= mouse_delta * pan_speed / zoom.x
		last_mouse_position = event.position

func _process(delta: float) -> void:
	if zoom_in:
		zoom_camera(zoom_speed * delta)
	if zoom_out:
		zoom_camera(-zoom_speed * delta)

func zoom_camera(amount: float):
	var new_zoom := zoom + Vector2(amount, amount)
	
	new_zoom.x = clamp(new_zoom.x, min_zoom, max_zoom)
	new_zoom.y = clamp(new_zoom.y, min_zoom, max_zoom)
	
	zoom = new_zoom
