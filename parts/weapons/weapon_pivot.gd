@tool
class_name WeaponPivot
extends Pivot


@export var config := WeaponConfig.new()


func _ready() -> void:
	if Engine.is_editor_hint():
		if not config:
			config = WeaponConfig.new()


func attack_animation() -> Tween:
	var sprite : Sprite2D = get_child(0)
	var factor := -1 if sprite.flip_h else 1
	sprite.offset.x = -10 * factor
	var t := create_tween()
	t.tween_property(sprite, "offset:x", 0, 0.1)
	return t
