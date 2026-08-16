class_name ColorBox
extends NinePatchRect

@export var default_texture: CompressedTexture2D
@export var hovered_texture: CompressedTexture2D
@export var pressed_texture: CompressedTexture2D

var mouse_hovered: bool = false
signal selected(color: Color)

func set_color(color: Color):
	modulate = color

func _on_mouse_entered() -> void:
	mouse_hovered = true
	texture = hovered_texture

func _on_mouse_exited() -> void:
	mouse_hovered = false
	texture = default_texture

func _on_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("select"):
		texture = pressed_texture
	if event.is_action_released("select") and mouse_hovered:
		selected.emit(modulate)
		texture = hovered_texture
