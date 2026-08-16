class_name EnterStructurename
extends Control

signal name_submitted(name: String)

@onready var name_generator: TownNameGenerator = $RandomNameGenerator
@onready var line_edit: LineEdit = $MarginContainer/HBoxContainer/LineEdit


func _on_line_edit_text_submitted(new_text: String) -> void:
	if new_text == "":
		return
	name_submitted.emit(new_text)
	visible = false


func _on_random_pressed() -> void:
	line_edit.text = name_generator.generate_name(5, 10)
