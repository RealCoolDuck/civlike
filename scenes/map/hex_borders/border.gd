class_name Border

signal color_updated(new_value: Color)

var color: Color = Color.WHITE: 
	set(new_value):
		color = new_value
		color_updated.emit(new_value)
var contents: Dictionary[Vector2i, bool] = {}

func add_hex(coords: Vector2i):
	contents[coords] = true
