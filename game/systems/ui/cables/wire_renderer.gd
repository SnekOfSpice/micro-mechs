extends Node2D


var wires : Array[Line2D]


## get a wire and save it locally
func get_wire() -> Line2D:
	var wire := Line2D.new()
	wires.append(wire)
	return wire



func _draw_wire(line : Line2D, from : Vector2, to : Vector2):
	var flip : int
	if to.x > from.x:
		flip = 1
	else:
		flip = -1
	
	var distance : float = from.distance_to(to)
	
	var handle := distance * 0.4
	
	var curve := Curve2D.new()
	curve.bake_interval = 0.25 * distance # idk I like the look
	curve.add_point(from, Vector2.ZERO, Vector2(handle, 0) * flip)
	curve.add_point(to, Vector2(-handle, 0) * flip, Vector2.ZERO)
	
	# feed points of path into line
	line.points = curve.get_baked_points()
