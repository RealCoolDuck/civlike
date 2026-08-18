class_name StructureLabel
extends Node2D

@onready var name_label: Label = $PanelContainer/HBoxContainer/Name
@onready var coin_label: IconLabel = $PanelContainer/HBoxContainer/Coins
@onready var population_label: IconLabel = $PanelContainer/HBoxContainer/People

func set_coins(amount: int):
	coin_label.text = str(amount)
	coin_label.update()

func set_population(amount: int):
	population_label.text = str(amount)
	population_label.update()
	

func set_structure_name(new_name: String):
	name_label.text = new_name

func set_structure_name_color(color: Color):
	name_label.add_theme_color_override("font_color", color)
