class_name CustomButton
extends TextureRect

@export var button_normal: CompressedTexture2D:
	set(new):
		button_normal = new
		texture = button_normal
@export var button_hovered: CompressedTexture2D
@export var button_pressed: CompressedTexture2D

signal pressed

func _ready() -> void:
	texture = button_normal

func _on_mouse_entered() -> void:
	texture = button_hovered

func _on_mouse_exited() -> void:
	texture = button_normal

func _on_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("select"):
		texture = button_pressed
	elif event.is_action_released("select"):
		texture = button_normal
		pressed.emit()
