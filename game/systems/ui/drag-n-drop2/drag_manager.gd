extends Node2D

## time in ms at which releasing the mouse button will not drop the dragged content again
var BEGIN_DRAG_MINIMUM_DURATION : int = 100
var hover_candidates := []
var last_click_time : int


var current_ui : Control
var last_clicked_offset : Vector2

var last_clicked_slot : Slot:
	set(value):
		var prev = last_clicked_slot
		last_clicked_slot = value
		
		# ugly placeholder
		if last_clicked_slot:
			last_clicked_offset = last_clicked_slot.get_local_mouse_position()
			if current_ui: current_ui.queue_free()
			current_ui = SlotFactory.make_slot_ui(last_clicked_slot.data)
			current_ui.mouse_filter = Control.MOUSE_FILTER_IGNORE
			add_child(current_ui)
			current_ui.global_position = last_clicked_slot.ui.global_position
		else:
			current_ui.queue_free()
		_update_ui_targets()
var _currently_hovering_slot : Slot:
	set(value):
		_currently_hovering_slot = value
		if value == null:
			_update_ui_targets()
		if value:
			print("current hover ", value.name)
			value.set_hover_highlight(true)
			if value.category != Slot.Category.PLAYER_MOVE:
				_update_ui_targets()
		if _currently_hovering_slot:
			_command_set_card_preview(_currently_hovering_slot.data)
		else:
			_command_set_card_preview(null)
			


func _update_ui_targets():
	var data_category := -1
	if last_clicked_slot or _currently_hovering_slot:
		var data : SlotData 
		if last_clicked_slot:
			data = last_clicked_slot.data
		if not data and _currently_hovering_slot:
			data = _currently_hovering_slot.data
		if data:
			if data is ToolData:
				data_category = Slot.Category.TOOL
			elif data is PatternData:
				data_category = Slot.Category.PATTERN
			elif data is PlayerMoveData:
				data_category = Slot.Category.PLAYER_MOVE
			elif data is ItemStackData:
				data_category = Slot.Category.ITEM_STACK
			elif data is ShipComponentData:
				data_category = Slot.Category.SHIP_COMPONENT
			elif data is EmergencyData:
				data_category = Slot.Category.EMERGENCY
	if data_category == -1:
		LocatorService.ui.set_ui_targets([], data_category)
		return
			
	
	if _currently_hovering_slot:
		if _currently_hovering_slot.void_data:
			return
		LocatorService.ui.set_ui_targets(_currently_hovering_slot.get_target_objects(), data_category)
	else:
		if last_clicked_slot:
			LocatorService.ui.set_ui_targets(last_clicked_slot.get_target_objects(), data_category)
		else:
			LocatorService.ui.set_ui_targets([], data_category)


func _process(_delta: float) -> void:
	if current_ui:
		var mouse_pos := get_viewport().get_mouse_position()
		current_ui.position = current_ui.position.move_toward(mouse_pos - last_clicked_offset, 200)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.is_released():
				_handle_release()


func _clear():
	#if currently_hovering_slot: currently_hovering_slot.set_active_highlight(false)
	if last_clicked_slot: last_clicked_slot.set_active_highlight(false)
	#currently_hovering_slot = null
	last_clicked_slot = null


func _can_transfer() -> bool:
	if not _currently_hovering_slot:
		var potential_target := find_hover_target()
		if potential_target:
			_currently_hovering_slot = potential_target
		#_handle_release()
		
	if last_clicked_slot and _currently_hovering_slot:
		if _currently_hovering_slot.can_receive(last_clicked_slot.data):
			if _currently_hovering_slot != last_clicked_slot:
				if (_currently_hovering_slot.category == last_clicked_slot.category) or \
					(_currently_hovering_slot.ignore_category or last_clicked_slot.ignore_category):
					if _currently_hovering_slot.data is ItemStackData:
						return _currently_hovering_slot.can_receive(last_clicked_slot.data)
					elif _currently_hovering_slot.is_empty():
						return true
	return false


func _handle_release():
	if not last_clicked_slot:
		return
	
	var button_press_duration = Time.get_ticks_msec() - last_click_time
	
	if button_press_duration > BEGIN_DRAG_MINIMUM_DURATION and _can_transfer():
		_transfer_data()
		return
	
	if _currently_hovering_slot == last_clicked_slot:
		return
	
	if not _currently_hovering_slot:
		_handle_untargeted_release()
		return
	if button_press_duration > BEGIN_DRAG_MINIMUM_DURATION:
		_handle_untargeted_release()
	
	hover_candidates.clear()


# punches through all hover targets until it finds one
# where the mouse is in it
# returns null if it fails
func find_hover_target() -> HoverTarget:
	var result : HoverTarget
	for hover_target : HoverTarget in get_tree().get_nodes_in_group("hover_target"):
		if hover_target.can_receive(last_clicked_slot.data):
			print("this COULD receive", hover_target.target.name, hover_target.last_reception_availability_time)
	var highest_time := -99999
	for hover_target : HoverTarget in get_tree().get_nodes_in_group("hover_target"):
		if hover_target.can_receive(last_clicked_slot.data):
			# this is where things break
			if hover_target.last_reception_availability_time >= highest_time:
				highest_time = hover_target.last_reception_availability_time
				result = hover_target
	
	return result


# if our current slot has a card that can be played without targets, play it
# otherwise clear
func _handle_untargeted_release():
	var potential_target := find_hover_target()
	if potential_target and not _currently_hovering_slot:
		_currently_hovering_slot = potential_target
		_handle_release()
		return
	if not last_clicked_slot.data:
		_clear()
		return
	var data : SlotData = last_clicked_slot.data
	if data is ToolData:
		if data.target == ToolData.UITargetType.UNTARGETED:
			if Global.get_local_player().inventory.of(
				Inventory.Items.ENERGY
			) >= data.cost:
				CardEffectResolver.handle_untargeted(data)
				SlotDataManager.set_slot_data(last_clicked_slot.path, null)
			else:
				Chat.send_system_message(
					"Not enough energy to play %s\n(You have %s/%s)" % [
						data.tech_id,
						Global.get_local_player().inventory.of(Inventory.Items.ENERGY),
						data.cost,
					]
				)
			_clear()
		else:
			_clear()
	else:
		_clear()


func _transfer_data():
	# special check for creating item stacks
	if _currently_hovering_slot.data is ItemStackData and last_clicked_slot.data is ItemStackData:
		var new_stack_size : int = last_clicked_slot.data.amount + _currently_hovering_slot.data.amount
		if new_stack_size <= Global.MAX_ITEM_STACK_SIZE:
			var new_data : ItemStackData = last_clicked_slot.data.copy()
			new_data.amount = new_stack_size
			SlotDataManager.set_slot_data(_currently_hovering_slot.path, new_data)
			SlotDataManager.set_slot_data(last_clicked_slot.path, null)
		else:
			var remainder : int = new_stack_size - Global.MAX_ITEM_STACK_SIZE
			var new_origin_data : ItemStackData = last_clicked_slot.data.copy()
			var new_target_data : ItemStackData = _currently_hovering_slot.data.copy()
			new_origin_data.amount = remainder
			new_target_data.amount = Global.MAX_ITEM_STACK_SIZE
			SlotDataManager.set_slot_data(_currently_hovering_slot.path, new_target_data)
			SlotDataManager.set_slot_data(last_clicked_slot.path, new_origin_data)
			
	else:
		SlotDataManager.set_slot_data(_currently_hovering_slot.path, last_clicked_slot.data.copy())
		SlotDataManager.set_slot_data(last_clicked_slot.path, null)
	#_currently_hovering_slot.data = last_clicked_slot.data
	#last_clicked_slot.data = null
	_clear()


func on_slot_clicked(slot : Slot):
	if slot.data: # check if the owner is also who we belong to
		if slot.private and slot.data.owner_id != multiplayer.get_unique_id():
			return
	
	add_hover_candidate(slot)
	
	# if the mouse button gets pressed while already holding a slot, test if the clicked slot can receive
	# if yes, transfer the data
	if last_clicked_slot and _currently_hovering_slot:
		if _currently_hovering_slot != last_clicked_slot and _can_transfer():
			_transfer_data()
			return
		else:
			_clear()
			return
	
	if last_clicked_slot: last_clicked_slot.set_active_highlight(false)
	
	# if we're already carrying a slot and the one we're clicking on can't receive,
	# return so we don't immediately pick up the new data but just bounce off
	if last_clicked_slot and not slot.is_empty():
		return
	
	if slot.data:
		slot.set_active_highlight(true)
		last_click_time = Time.get_ticks_msec()
		last_clicked_slot = slot
	


func add_hover_candidate(candidate : Slot):
	_remove_invalid_candidates()
	if candidate.data:
		if candidate.private and candidate.data.owner_id != multiplayer.get_unique_id():
			return
	
	if not hover_candidates.has(candidate):
		hover_candidates.append(candidate)
	
	for slot : Slot in get_tree().get_nodes_in_group(Groups.SLOTS):
		if slot != candidate:
			slot.set_hover_highlight(false)
	
	_currently_hovering_slot = hover_candidates.back()


func _remove_invalid_candidates():
	var actually_valid := []
	var i := 0
	var goal_size := hover_candidates.size()
	while i < goal_size:
		var maybe_valid = hover_candidates[i]
		var is_valid := false
		if is_instance_valid(maybe_valid):
			if (maybe_valid as Slot).is_mouse_in():
				actually_valid.append(maybe_valid)
		if is_valid:
			hover_candidates.remove_at(i)
			i -= 1
		i += 1
	
	hover_candidates = actually_valid


func remove_hover_candidate(candidate : Slot):
	_remove_invalid_candidates()
	if hover_candidates.has(candidate):
		hover_candidates.erase(candidate)
	candidate.set_hover_highlight(false)
	if hover_candidates.is_empty():
		_currently_hovering_slot = null
	else:
		_currently_hovering_slot = hover_candidates.back()






func _command_set_card_preview(card_data : SlotData):
	var c := CommandSetCardPreview.new()
	c.player_id = multiplayer.get_unique_id()
	c.card_data = card_data
	CommandHandler.add_command_to_authority(c)
