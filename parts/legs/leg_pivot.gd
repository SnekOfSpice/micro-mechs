@tool
extends Pivot



@export var config := LegConfig.new()


func _ready() -> void:
	if Engine.is_editor_hint():
		if not config:
			config = LegConfig.new()
