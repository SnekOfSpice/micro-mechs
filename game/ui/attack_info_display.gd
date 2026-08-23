extends PanelContainer
class_name AttackInfoDisplay


enum Perspective {
	ATTACKER,
	DEFENDER
}


func render(weapon_config : WeaponConfig, perspective : Perspective):
	for container : Control in %Containers.get_children():
		container.hide()
	
	if perspective == Perspective.ATTACKER:
		add_theme_stylebox_override("panel", load("res://game/ui/attack_style_box_attacker.tres"))
		weapon_config.uses
		var energy := weapon_config.energy_consumption_self
		%EnergyContainer.visible = energy > 0
		%EnergyLabel.text = str(energy)
		var heat := weapon_config.heat_generation_self
		%HeatContainer.visible = heat > 0
		%HeatLabel.text = str(heat)
		var rocket := weapon_config.rocket_consumption
		%RocketsContainer.visible = rocket > 0
		%RocketsLabel.text = str(rocket)
		var bullet := weapon_config.bullet_consumption
		%BulletsContainer.visible = bullet > 0
		%BulletsLabel.text = str(bullet)
		
	
	elif perspective == Perspective.DEFENDER:
		%DamageContainer.visible = weapon_config.damage.x > 0 or weapon_config.damage.y > 0
		%DamageTypeIcon.texture = load("res://icon_%s.png" % WeaponConfig.DamageType.keys()[weapon_config.damage_type].to_lower())
		%DamageRangeLabel.text = "%s - %s" % [weapon_config.weapon_range.x, weapon_config.weapon_range.y]
		
		add_theme_stylebox_override("panel", load("res://game/ui/attack_style_box_defender.tres"))
		
		var energy := weapon_config.energy_consumption_target
		%EnergyContainer.visible = energy > 0
		%EnergyLabel.text = str(energy)
		var heat := weapon_config.heat_generation_target
		%HeatContainer.visible = heat > 0
		%HeatLabel.text = str(heat)
		
		var knockback := weapon_config.knockback
		%KnockbackContainer.visible = knockback > 0
		%KnockbackLabel.text = str(knockback)
	await RenderingServer.frame_post_draw
	size = Vector2.ZERO
	
