@tool
class_name WeaponPivot
extends Pivot


@export var config := WeaponConfig.new()


func _ready() -> void:
	if Engine.is_editor_hint():
		if not config:
			config = WeaponConfig.new()


func attack_animation(attack_target : Mech) -> float:
	var target_position : Vector2 = attack_target.get_projectile_point()
	
	var sprite : Sprite2D = get_child(0)
	var factor := -1 if sprite.flip_h else 1
	sprite.offset.x = -10 * factor
	var projectile := ColorRect.new()
	match config.damage_type:
		WeaponConfig.DamageType.Kinetic:
			projectile.color = Color.YELLOW
		WeaponConfig.DamageType.Electric:
			projectile.color = Color.AQUA
		WeaponConfig.DamageType.Explosive:
			projectile.color = Color.CRIMSON
	
	projectile.custom_minimum_size = Vector2.ONE * config.damage.x * 2
	Global.battle_stage.add_child(projectile)
	projectile.global_position = global_position# get barrel
	var distance_to_target := global_position.distance_to(target_position)
	# TODO put appearence into config
	var recoil_duration := 0.1
	var projectile_flight_duration = distance_to_target / 750.0
	var t := create_tween()
	t.set_parallel()
	t.tween_property(sprite, "offset:x", 0, recoil_duration)
	t.tween_property(projectile, "position", target_position, projectile_flight_duration)
	var projectile_timer := get_tree().create_timer(projectile_flight_duration)
	projectile_timer.timeout.connect(func():
		projectile.queue_free()
		attack_target.handle_attacked(config))
	return max(recoil_duration, projectile_flight_duration)
