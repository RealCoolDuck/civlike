extends HBoxContainer

signal button_pressed

@export var button_texture: CompressedTexture2D
@export var button_hovered_texture: CompressedTexture2D
@export var button_pressed_texture: CompressedTexture2D

@export var text: String

@onready var label: Label = $Label
@onready var button: CustomButton = $MarginContainer/Button

func _ready() -> void:
	label.text = text
	button.button_normal = button_texture
	button.button_hovered = button_hovered_texture
	button.button_pressed = button_pressed_texture


func _on_button_pressed() -> void:
	button_pressed.emit()
