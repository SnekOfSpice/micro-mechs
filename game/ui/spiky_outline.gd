@tool
extends Control
class_name SpikyOutline


@export var spike_count : int:
	set(value):
		if spike_count == value:
			return
		spike_count = value
		_rebuild()


@export var radius : float:
	set(value):
		if radius == value:
			return
		radius = value
		_rebuild()


func _rebuild():
	if not is_inside_tree():
		return
	
	if spike_count < 0:
		return
	
	var overshoot := get_child_count() - spike_count
	if overshoot > 0:
		for i in overshoot:
			get_child(0).free()
	elif overshoot < 0:
		for i in abs(overshoot):
			var anchor := Control.new()
			anchor.size = Vector2.ZERO
			var spike := TextureRect.new()
			spike.texture = load("res://game/ui/spike.png")
			anchor.add_child(spike)
			add_child(anchor)
			anchor.owner = get_tree().edited_scene_root
			spike.owner = get_tree().edited_scene_root
			anchor.mouse_filter = Control.MOUSE_FILTER_IGNORE
			spike.mouse_filter = Control.MOUSE_FILTER_IGNORE
			spike.position.x -= spike.size.x * 0.5
	
	var rotation_per_spike : float = TAU / float(spike_count)
	for i in get_child_count():
		var anchor : Control = get_child(i)
		anchor.rotation = rotation_per_spike * i
		var spike : TextureRect = anchor.get_child(0)
		spike.position.y = radius
		
