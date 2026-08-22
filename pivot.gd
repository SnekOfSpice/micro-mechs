@tool
class_name Pivot
extends Marker2D


@export var in_front := true:
	set(value):
		in_front = value
		if in_front:
			z_index = 1
		else:
			z_index = -1


func set_flipped(flipped : bool):
	var sprite : Sprite2D = get_child(0)
	if not sprite:
		return
	if sprite.flip_h == flipped:
		return
	
	if sprite.centered:
		sprite.position.x = -sprite.position.x
	else:
		var width := sprite.texture.get_width()
		if name == "Leg1Front": print("flipped ", sprite.flip_h, " pos ", sprite.position.x )
		if sprite.flip_h:
			sprite.position.x = -(sprite.position.x + width)
		else:
			sprite.position.x = -(width + sprite.position.x)
		if name == "Leg1Front": print("position is now ", sprite.position.x)
	sprite.flip_h = flipped
	in_front = not in_front
