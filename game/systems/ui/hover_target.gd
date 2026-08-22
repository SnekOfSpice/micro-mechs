@tool
extends Slot
class_name HoverTarget

## used by PlayerUI when hovering over certain UI elements
## such as cards that can target
## and PawnUISource when in the ship view

var camera : Camera3D
var target : Node3D

# checking in real time didn't work out so we're saving it as a
# variable derived from the correct visualization in the process function
var could_receive := false

# horrible hack
var could_receive_last_frame := false
var last_reception_availability_time : int

func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		return
	if not camera:
		return
	if not target:
		return
	
	if not is_visible_in_tree():
		return
	
	position = camera.unproject_position(target.global_position)
	if ui:
		size = ui.size
	if target is ShipRoom:
		%Line2D.global_position = position - camera.unproject_position(target.global_position)
		var corners : PackedVector2Array = target.get_outline_polygon_vertices_unprojected(camera)
		%Line2D.points = corners
		
		var is_mouse_in := Geometry2D.is_point_in_polygon(
			get_global_mouse_position(),
			corners,
		)
		%Line2D.default_color = Color.WHITE if is_mouse_in else Color.GRAY
		if could_receive != is_mouse_in:
			EventBus.hover_target_availability_changed.emit(target, is_mouse_in)
		if is_mouse_in and not could_receive:
			last_reception_availability_time = Time.get_ticks_msec()
		could_receive = is_mouse_in
		
		texture = null
		mouse_filter = Control.MOUSE_FILTER_IGNORE
	if could_receive:
		print(target.name)

func get_global_line_points() -> PackedVector2Array:
	var points : PackedVector2Array = %Line2D.points
	
	for i in points.size():
		points[i] = points[i] + %Line2D.global_position
		
	
	return points


# overrides the base func
# gets queried by DragManager even if the mouse isn't technically in this control
# this is used to find any viable places to dump a data into
# because ship rooms look fucked up perspective-wise bc of camera stuff
func can_receive(_query_data : SlotData) -> bool:
	if not is_visible_in_tree():
		return false
	if target is ShipRoom:
		return could_receive
	return super(_query_data)
	
