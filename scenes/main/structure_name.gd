extends Label

func _on_info_panel_enter() -> void:
	text = GameState.selected_structure.structure_name
	add_theme_color_override("font_color", GameState.selected_structure.border.color)
