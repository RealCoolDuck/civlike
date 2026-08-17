class_name IconLabel
extends HBoxContainer

@export var icon: CompressedTexture2D
@export var text: String

@onready var texture_rect: TextureRect = $TextureRect
@onready var label: Label = $Label

func _ready() -> void:
	texture_rect.texture = icon
	label.text = text

func update():
	texture_rect.texture = icon
	label.text = text
