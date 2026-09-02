extends Node3D
class_name BattleStage


var mech1 : Mech
var mech2 : Mech
var commands_this_turn := []
var commands_begun_this_turn := []


var _tile_data := []

func _on_tile_data_changed():
	%TileDataLabel.text = ""
	for data in _tile_data:
		if data == null:
			%TileDataLabel.text += " 0 "
		elif data is Mech:
			%TileDataLabel.text += " M "
		else:
			%TileDataLabel.text += " x "

const ARENA_SIZE_RANGE := Vector2i(8, 13)


func _ready() -> void:
	CommandHandler.command_executed.connect(_on_command_executed)
	CommandHandler.command_executing.connect(_on_command_executing)
	var config := ResourceLoader.load("user://mech_config.tres")
	mech1 = preload("res://mech.tscn").instantiate()
	%BattleLine.add_child(mech1)
	mech1.config = config
	
	mech2 = preload("res://mech.tscn").instantiate()
	%BattleLine.add_child(mech2)
	mech2.config = MechConfig.get_randomized()
	
	var agent := MechAgent.new()
	mech2.add_child(agent)
	
	Global.player_mech = mech1
	Global.npc_mech = mech2
	Global.battle_stage = self
	
	_tile_data.clear()
	_tile_data.resize(randi_range(ARENA_SIZE_RANGE.x, ARENA_SIZE_RANGE.y))
	
	var player_start_position := randi_range(2, 4)
	mech1.move_to_index(player_start_position)
	var other_start_position := player_start_position + randi_range(1, 5)
	other_start_position = clampi(other_start_position, 0, ARENA_SIZE_RANGE.y)
	mech2.move_to_index(other_start_position)
	
	
	
	EventBus.mech_died.connect(_on_mech_died)
	
	_begin_battle()
	#mech1.mech_loaded.connect(_decrement_blocker, CONNECT_ONE_SHOT)
	#mech2.mech_loaded.connect(_decrement_blocker, CONNECT_ONE_SHOT)
	
	await get_tree().process_frame
	%PlayerHUD.register_mechs_to_track(mech1, mech2)


func _process(delta: float) -> void:
	_update_flips()

func handle_spot_change(mech : Mech, old_spot : int, new_spot : int):
	_tile_data[old_spot] = null
	_tile_data[new_spot] = mech
	_on_tile_data_changed()

func get_spot(mech : Mech) -> int:
	for i in _tile_data.size():
		if _tile_data[i] == mech:
			return i
	return -1


func is_spot_free(index : int) -> bool:
	if index < 0:
		return false
	if index >= _tile_data.size():
		return false
	return _tile_data[index] == null


var blockers := 1
func _decrement_blocker():
	blockers -= 1
	if blockers <= 0:
		_begin_battle()

func _begin_battle():
	_update_flips()
	
	await get_tree().process_frame
	mech1.initialize_combat_stats()
	mech2.initialize_combat_stats()
	
	%PlayerHUD.populate_player_actions(mech1.get_action_list())
	Global.active_mech = mech1
	PhaseManager.begin_match()


func _update_flips():
	if mech1.global_position != mech2.global_position:
		mech1.look_at(mech2.global_position)
		mech2.look_at(mech1.global_position)
	#mech1.set_flip(mech1.global_position.x > mech2.global_position.x)
	#mech2.set_flip(mech2.global_position.x > mech1.global_position.x)
#
#
#func move_mech(mech : Mech, distance : int):
	#var mech_index := mech.get_parent().get_index()
	#move_mech_to(mech, mech_index + distance)
#
#
#func move_mech_to(mech : Mech, slot_index : int):
	#mech.reparent(get_slot(slot_index))
	#mech.position = get_slot_position(slot_index)
#
#func get_slot(slot_index : int) -> TextureRect:
	#if slot_index < 0 or slot_index >= %MechSlots.get_child_count():
		#push_warning("tried to get slot outside of range")
		#slot_index = clampi(slot_index, 0, %MechSlots.get_child_count() - 1)
	#
	#var slot : TextureRect = %MechSlots.get_child(slot_index)
	#return slot
#
#
#func get_slot_position(slot_index : int) -> Vector2:
	#var slot := get_slot(slot_index)
	#
	#var origin := slot.global_position
	#
	#origin.x += slot.texture.get_size().x * 0.5
	#origin.y = slot.texture.get_height()
	#return origin
	#



func command_do_attack(attacking_mech : Mech, weapon_index : int):
	var c := CommandDoAttack.new()
	c.attacker = attacking_mech
	c.target = Global.get_other_mech(attacking_mech)
	c.weapon_index = weapon_index
	CommandHandler.add_command(c)


func _on_main_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://game/main_menu/main_menu.tscn")


func _on_command_executing(command : Command):
	commands_begun_this_turn.append(command)
	EventBus.commands_begun_this_turn_changed.emit()
func _on_command_executed(command : Command):
	commands_this_turn.append(command)
	if commands_this_turn.size() >= Global.active_mech.combat_stats.actions_left:
		PhaseManager.advance_phase()
	EventBus.commands_this_turn_changed.emit()


func hide_range():
	for child in %Highlight.get_children():
		child.queue_free()

func highlight_range(range : Vector2):
	# swap if reversed
	if range.x > range.y:
		var a := range.x
		range.x = range.y
		range.y = a
	
	for child in %Highlight.get_children():
		child.queue_free()
	
	for i in range(range.x, range.y + 1):
		var highlight := Label3D.new()
		highlight.fixed_size = true
		highlight.text = "____"
		highlight.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		highlight.no_depth_test = true
		if not is_spot_free(i):
			highlight.modulate = Color.RED
		%Highlight.add_child(highlight)
		highlight.position.z = i * Mech.WIDTH + Mech.HALF_WIDTH
	return
	
	%Highlight.show()
	%Highlight.global_position = %BattleLine.global_position
	%Highlight.points = PackedVector2Array([
		Vector2(range.x * Mech.WIDTH - Mech.HALF_WIDTH, 0),
		Vector2(range.y * Mech.WIDTH + Mech.HALF_WIDTH, 0),
	])


func _on_mech_died(mech : Mech):
	pass


func is_in_arena(index : int)  -> bool:
	return index >= 0 and index < _tile_data.size()


func add_floating_number(damage : int, at : Vector3):
	var label := Label.new()
	label.z_index = 5
	$CanvasLayer.add_child(label)
	label.pivot_offset_ratio = Vector2(0.5, 0.5)
	label.global_position = $BattleCamera.unproject_position(at)
	label.text = "-%s" % damage
	var t := create_tween()
	t.tween_property(label, "position", Vector2(
		label.position.x + randf_range(-20, 20),
		label.position.y - 50
	),
	3)
	t.set_parallel()
	label.scale = Vector2.ONE * clamp(damage, 2.5, 10)
	t.tween_property(label, "scale", Vector2.ZERO, 1).set_delay(2).set_trans(Tween.TRANS_CUBIC)
	t.finished.connect(label.queue_free)
