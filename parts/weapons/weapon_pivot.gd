@tool
class_name WeaponPivot
extends Pivot


@export var config := WeaponConfig.new()


func _ready() -> void:
	if Engine.is_editor_hint():
		if not config:
			config = WeaponConfig.new()
