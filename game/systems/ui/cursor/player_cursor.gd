extends Sprite2D
class_name PlayerCursor


func _enter_tree() -> void:
	# can't free because this is spawned via multiplayer spawner
	# if this gets freed, the remotes also get freed
	if get_multiplayer_authority() == multiplayer.get_unique_id():
		hide()


func _process(_delta: float) -> void:
	if not get_window().has_focus():
		return
	if not is_multiplayer_authority():
		return
	position = lerp(position, get_global_mouse_position(), 0.5)
