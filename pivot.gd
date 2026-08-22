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
