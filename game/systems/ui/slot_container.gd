@tool
extends Container
class_name SlotContainer


@export var slot_count := 0:
	set(value):
		slot_count = value
		if not is_inside_tree():
			return
		
		var child_count : int = get_child_count()
		if child_count == slot_count:
			return
		
		# add additional slots
		if child_count < slot_count:
			var difference := slot_count - child_count
			for i in difference:
				var receiver : Slot = load("res://game/systems/ui/drag-n-drop2/slot.tscn").instantiate()
				receiver.path = path_prefix + str(child_count + i)
				if texture_override:
					receiver.texture = texture_override
				add_child(receiver)
				receiver.owner = get_tree().edited_scene_root
		
		# cull excess slots
		if child_count > slot_count:
			for i in child_count - slot_count:
				var slot = get_child(get_child_count() - 1)
				slot.free()
		
		_update_collision_bits()
@export var path_prefix : String = "":
	set(value):
		path_prefix = value
		for slot : Slot in get_children():
			slot.path = "%s/%s" % [path_prefix, slot.get_index()]

var slots: Array[Slot]:
	get():
		var result : Array[Slot] = []
		for child : Slot in get_children():
			result.append(child)
		return result

@export var category : Slot.Category = Slot.Category.NONE:
	set(value):
		category = value
		_update_collision_bits()


@export var texture_override : Texture2D:
	set(value):
		texture_override = value
		for slot in slots:
			slot.texture = value

func _update_collision_bits():
	for child : Slot in get_children():
		child.category = category
