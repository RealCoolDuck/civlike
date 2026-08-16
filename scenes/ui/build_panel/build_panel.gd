extends Control

signal structure_upgade_pressed
signal exit

func _on_texture_button_pressed() -> void:
	structure_upgade_pressed.emit()

func _on_bg_gui_input(event: InputEvent) -> void:
	if event.is_action_released("select"):
		exit.emit()
		visible = false

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("escape"):
		exit.emit()
		visible = false
