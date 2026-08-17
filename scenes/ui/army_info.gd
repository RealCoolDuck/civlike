extends VBoxContainer

@export var panel: CustomPanel


var icon_label_scene = preload("res://scenes/ui/icon_label.tscn")
var army_texture = preload("res://assets/sprites/train_army.png")


func _ready():
	panel.enter.connect(_on_enter)
	panel.exit.connect(_on_exit)

func _on_enter():
	var units := GameState.selected_movable.units
	
	for unit in units.keys():
		var instance: IconLabel = icon_label_scene.instantiate()
		add_child(instance)
		instance.icon = army_texture
		instance.text = Enums.UNIT_TYPE_TO_STRING[unit] + '   ' + str(units[unit])
		instance.update()

func _on_exit():
	for child in get_children():
		child.queue_free()
	
	
