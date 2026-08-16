class_name StructureInfo
extends Control

signal exit
signal edit_structure_title(structure: Structure)

@onready var title_label: Label = $MarginContainer/PanelContainer/VBoxContainer/HBoxContainer/Title
@onready var money_label: Label = $MarginContainer/PanelContainer/VBoxContainer/HBoxContainer2/Money
@onready var population_label: Label = $MarginContainer/PanelContainer/VBoxContainer/HBoxContainer3/Population

var structure: Structure = null

func _on_bg_gui_input(event: InputEvent) -> void:
	if event.is_action_released("select"):
		exit.emit()
		visible = false

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("escape"):
		exit.emit()
		visible = false

func set_structure(new_structure: Structure):
	title_label.text = new_structure.structure_name
	title_label.add_theme_color_override("font_color", new_structure.border.color)
	money_label.text = str(new_structure.money)
	population_label.text = str(new_structure.population)
	structure = new_structure

func _on_edit_title_button_pressed() -> void:
	edit_structure_title.emit(structure)
