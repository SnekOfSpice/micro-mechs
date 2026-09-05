extends Button
class_name ActionButton


var action : Action:
	set(value):
		action = value
		_rebuild()


func _ready() -> void:
	EventBus.request_action_rebuild.connect(_rebuild)
	CommandHandler.command_executed.connect(func(_c): _rebuild())




func is_mouse_in() -> bool:
	if not get_viewport():
		return false
	var mouse_pos := get_local_mouse_position()
	return mouse_pos.x >= 0 and mouse_pos.y >= 0 and mouse_pos.x <= size.x and mouse_pos.y <= size.y


func _rebuild():
	if is_mouse_in():
		_on_mouse_entered()
	if action is ActionCoolDown:
		text = "cool down"
		%ActionIcon.texture = load("res://game/ui/buttons/cool_down.png")
	elif action is ActionMove:
		text = "move %s" % action.distance
		%ActionIcon.texture = load("res://game/ui/buttons/move.png")
		%ActionIcon.flip_h = Global.player_mech.flipped
		
	elif action is ActionWeapon:
		text = "attack"
		%ActionIcon.texture = load("res://game/ui/buttons/weapon.png")
		%WeaponIcon.texture = load("res://parts/weapons/icons/%s.png" % action.config.tech_id)
	elif action is ActionStomp:
		text = "stomp"
		%ActionIcon.texture = load("res://game/ui/buttons/stomp.png")
	elif action is ActionFlip:
		text = "flip"
		%ActionIcon.texture = load("res://game/ui/buttons/flip.png")
	
	var can_do : Action.CanDoResult = action.can_do()
	if can_do == Action.CanDoResult.CAN_DO:
		disabled = false
	else:
		disabled = true
	display_can_do_result(can_do)


func display_can_do_result(result : Action.CanDoResult):
	if result == Action.CanDoResult.CAN_DO:
		%CanDoResult.hide()
		%ActionIcon.modulate.a = 1
		return
	%CanDoResult.show()
	var can_do_name : String = Action.CanDoResult.keys()[result]
	can_do_name = can_do_name.to_lower()
	%CanDoResult.texture = load("res://game/ui/can_do_results/%s.png" % can_do_name)
	%ActionIcon.modulate.a = 0.5



func _on_pressed() -> void:
	_on_mouse_exited()
	if CommandHandler.awaiting_execution:
		return
	action.do()
	Global.player_mech.combat_stats.actions_left -= 1
	await get_tree().process_frame
	EventBus.request_action_rebuild.emit()


var spike_tween

func _on_mouse_entered() -> void:
	Global.visualize_action_range(action, Global.player_mech)
	if spike_tween:
		spike_tween.kill()
	
	if disabled:
		return
	if not find_child("SpikyOutline"):
		return
	spike_tween = create_tween()
	spike_tween.set_parallel()
	%SpikyOutline.radius = 100
	%SpikyOutline.rotation = PI
	spike_tween.tween_property(%SpikyOutline, "spike_count", 13, .5).set_trans(Tween.TRANS_ELASTIC)
	spike_tween.tween_property(%SpikyOutline, "radius", 50, .5).set_trans(Tween.TRANS_EXPO)
	spike_tween.tween_property(%SpikyOutline, "rotation", 0, 1.0).set_trans(Tween.TRANS_BOUNCE)


func _on_mouse_exited() -> void:
	Global.battle_stage.hide_range(Global.player_mech)
	Global.hud.hide_weapon_visualizer()
	if spike_tween:
		spike_tween.kill()
	if not find_child("SpikyOutline"):
		return
	spike_tween = create_tween()
	%SpikyOutline.rotation = 0
	spike_tween.tween_property(%SpikyOutline, "spike_count", 0, .2)
