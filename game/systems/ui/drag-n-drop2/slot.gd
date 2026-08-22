@tool
extends TextureRect
class_name Slot


signal data_changed(d : SlotData)

enum Category {
	NONE = -1,
	TOOL,
	PATTERN,
	ITEM_STACK,
	SHIP_COMPONENT,
	PLAYER_MOVE,
	EMERGENCY,
}

# remember to define corresponding constants!
@export_enum("Tool", "Pattern", "Item Stack", "Ship Component", "Player Move") var category := 0
## use with caution. should only be used if you handle data filtering in [method can_receive].
## currently this is the ugly workaround to also accomodate card data without the tool/pattern distinction
@export var ignore_category := false
## a unique identifier for this specific slot that's consistent across the network
## (get's forked into player UI by player IDs)
## is usually manually defined
@export var path : String = "":
	set(value):
		if path.is_empty() and (not value.is_empty()) and (not Engine.is_editor_hint()):
			path = value
			SlotDataManager.register(self)
			return
		path = value
		
## Can only be edited by the player whose multiplayer id matches the owner_id if [member data].
@export var private := false
## After setting [member data], [member data] will become null.
## Useful for when you want to create sinks / one-off interactions.
@export var void_data := false
## Transferring data to another Slot won't clear the data from this Slot.
@export var infinite_data := false
## Slots register themselves to SlotDataManager when they enter the tree.
## If their [member path] is empty, SlotDataManager will throw an error.
## This can suppress that error if you know you'll set the path later
## (e.g. during initialization)
@export var suppress_first_register_warning := false

var ui : SlotUI
@export var data : SlotData: #TODO: this is redundant with SlotUI.data, consider changing that ...
	set(value):
		if value == null and infinite_data:
			return
		data = value
		if data:
			print(name, " setting data ", data.tech_id)
		else:
			print(name, " nulll data")
		if data:
			if data is ToolData:
				category = Category.TOOL
			elif data is PatternData:
				category = Category.PATTERN
			elif data is ShipComponentData:
				category = Category.SHIP_COMPONENT
			elif data is ItemStackData:
				category = Category.ITEM_STACK
			elif data is PlayerMoveData:
				category = Category.PLAYER_MOVE
		
		if ui: ui.queue_free()
		ui = SlotFactory.make_slot_ui(data)
		if ui:
			add_child(ui, false, Node.INTERNAL_MODE_BACK)
		else:
			if ui:
				ui.queue_free()
		if Engine.is_editor_hint():
			ui.owner = get_tree().edited_scene_root
		
		if data:
			data_changed.emit(data.copy())
		else:
			data_changed.emit(data)
		
		if void_data and data:
			# TODO make this into a better system
			# this is a quick hack to get the playtest running
			print("voiding data", data)
			print("PLEASE HANDLE THIS")
			set.call_deferred("data", null)

func is_empty() -> bool:
	return not data


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	gui_input.connect(_on_gui_input)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	
	add_to_group(Groups.SLOTS)
	
	SlotDataManager.register(self)



func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.is_pressed():
				DragManager.on_slot_clicked(self)
			if event.is_released():
				DragManager._handle_release()


func _on_mouse_entered() -> void:
	set_hover_highlight(true)
	DragManager.add_hover_candidate(self)


func _on_mouse_exited() -> void:
	if data:
		if data.owner_id != multiplayer.get_unique_id():
			return
	DragManager.remove_hover_candidate(self)


func set_hover_highlight(value : bool):
	if not ui: return
	if value:
		ui.current_state = SlotUI.State.FOCUSED
	else:
		ui.current_state = SlotUI.State.NEUTRAL


func set_active_highlight(value : bool):
	if not ui: return
	if value:
		ui.current_state = SlotUI.State.DRAGGED
	else:
		ui.current_state = SlotUI.State.NEUTRAL
	

func get_target_objects() -> Array:
	if not data:
		return []
	
	return data.get_target_objects()



func can_receive(_query_data : SlotData) -> bool:
	if data is ItemStackData and _query_data is ItemStackData:
		return data.item == _query_data.item and data.amount < Global.MAX_ITEM_STACK_SIZE
	return true


func lock():
	if ui:
		ui.current_state = SlotUI.State.LOCKED
	# TODO probably do something more flexible than setting the
	# mouse filter to ignore
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	# the lock texture is super placeholder
	%Lock.show()

func unlock():
	if ui:
		ui.current_state = SlotUI.State.NEUTRAL
	mouse_filter = Control.MOUSE_FILTER_STOP
	%Lock.hide()



func is_mouse_in() -> bool:
	if self is HoverTarget:
		# has a custom implementation bc of outline drawing
		return get("could_receive")
	
	# but the default is just 2d
	var mouse_pos := get_local_mouse_position()
	return (mouse_pos.x >= 0 and mouse_pos.x <= size.x) and (mouse_pos.y >= 0 and mouse_pos.y <= size.y)
	
