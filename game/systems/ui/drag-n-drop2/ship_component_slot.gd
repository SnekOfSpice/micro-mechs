@tool
extends Slot
class_name ShipComponentSlot

@export var filter_prefix : String = ""


func can_receive(query_data : SlotData) -> bool:
	if query_data:
		return query_data.tech_id.begins_with(filter_prefix)
	return true
