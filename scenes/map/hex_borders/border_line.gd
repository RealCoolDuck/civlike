class_name BorderLine
extends Occupant

@onready var sprite: Sprite2D = $Sprite2D

func set_texture(texture: CompressedTexture2D):
	sprite.texture = texture
