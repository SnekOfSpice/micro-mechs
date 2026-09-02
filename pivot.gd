@tool
class_name Pivot
extends Marker3D


@export var in_front := true:
	set(value):
		in_front = value
		#if in_front:
			#z_index = 1
		#else:
			#z_index = -1
var _mesh : Node3D:
	get():
		if not _mesh:
			for child in get_children():
				if child is MeshInstance3D or child is Sprite3D:
					_mesh = child
					break
		return _mesh

func set_flipped(flipped : bool):
	return
	#if not _sprite:
		#return
	#if _sprite.flip_h == flipped:
		#return
	#
	#if _sprite.centered:
		#_sprite.position.x = -_sprite.position.x
	#else:
		#var width := _sprite.texture.get_width()
		#if _sprite.flip_h:
			#_sprite.position.x = -(_sprite.position.x + width)
		#else:
			#_sprite.position.x = -(width + _sprite.position.x)
	#_sprite.flip_h = flipped
	# sure what the hell ugh
	#if flipped:
	#print("pivot ", name, " needs to flip to ", flipped, " and is in front ", in_front)
	#in_front = not in_front
	#print("is now in front ", in_front)
	#else:
		#in_front = in_front
