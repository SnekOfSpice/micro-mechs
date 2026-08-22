@tool
extends Resource
class_name MechConfig


@export var torso_id := "":
	set(new_value):
		print(new_value)
		if torso_id != new_value:
			torso_id = new_value
			emit_changed()


@export var leg_id := "":
	set(new_value):
		if leg_id != new_value:
			leg_id = new_value
			emit_changed()


@export var weapon_list : PackedStringArray = []:
	set(new_value):
		if weapon_list != new_value:
			weapon_list = new_value
			emit_changed()
