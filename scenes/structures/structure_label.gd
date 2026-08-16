class_name StructureLabel
extends Node2D

@onready var name_label: Label = $PanelContainer/HBoxContainer/Name
@onready var coin_label: Label = $PanelContainer/HBoxContainer/Coins
@onready var population_label: Label = $PanelContainer/HBoxContainer/Population

func set_coins(amount: int):
	coin_label.text = str(amount)

func set_population(amount: int):
	population_label.text = str(amount)

func set_structure_name(name: String):
	name_label.text = name

func set_structure_name_color(color: Color):
	name_label.add_theme_color_override("font_color", color)
