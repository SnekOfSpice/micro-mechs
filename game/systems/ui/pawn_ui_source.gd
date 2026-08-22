@tool
extends Slot
class_name PawnUISource


var pawn : Pawn
var camera : Camera3D
var follow_target : Node3D



func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		return
	if not camera:
		return
	if not pawn:
		return
	position = camera.unproject_position(follow_target.global_position)
	if ui:
		size = ui.size
		position -= size * 0.5
