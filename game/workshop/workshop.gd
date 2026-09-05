extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for button : Button in %TorsoSelector.get_children():
		button.pressed.connect(
			func():
				%Mech.config.torso_id = button.text
				_update_weapons_selection()
		)
	for button : Button in %LegsContainer.get_children():
		button.pressed.connect(
			func():
				%Mech.config.leg_id = button.text
		)
	
	var config := ResourceLoader.load("user://mech_config.tres")
	if config:
		%Mech.config = config
		%Mech.config.changed.connect(_on_config_changed)
	_on_config_changed()
	_update_weapons_selection()
	_update_lines()
	%AttackInfos.hide()


func _update_lines():
	var torso_target = %Camera3D.unproject_position(%Mech.get_torso_position())
	var leg_target = %Camera3D.unproject_position(%Mech.get_leg_position())
	
	%TorsoLine.points = [torso_target, %TorsoSelector.global_position + Vector2(%TorsoSelector.size.x, 0)]
	%LegLine.points = [leg_target, %LegsContainer.global_position + Vector2(%LegsContainer.size.x, 0)]


func _on_config_changed():
	await get_tree().process_frame
	var combat_stats : CombatStats = %Mech.initialize_combat_stats()
	
	%MechStatusContainer.display_combat_stats(combat_stats)
	
	%MobilityLabel.text = str("Movement: ", %Mech._leg_config.movement)
	%MobilityLabel.text += str("\nStomp Damage: ", Global.vec2_to_range_string(%Mech._leg_config.stomp_damage))
	%MobilityLabel.text += str("  knockback", %Mech._leg_config.stomp_knockback)
	_update_lines()


func _update_weapons_selection():
	for child in %WeaponsSelection.get_children():
		child.queue_free()
	
	for line : Line2D in %WeaponLines.get_children():
		line.queue_free()
	
	var weapons := Global.get_weapon_configs()
	
	var weapon_count : int = %Mech.weapon_capacity
	for i in weapon_count:
		#var weapon_selected_here := weapons_selected[i]
		var selections := GridContainer.new()
		selections.columns = 3
		%WeaponsSelection.add_child(selections)
		
		for w in weapons:
			var button := Button.new()
			button.icon = load("res://parts/weapons/icons/%s.png" % w)
			button.pressed.connect(func():
				%Mech.config.set_weapon(i, w)
				)
			selections.add_child(button)
			
			button.mouse_entered.connect(func():
				%AttackInfos.show()
				var config : WeaponConfig = load("res://parts/weapons/configs/%s.tres" % w)
				%AttackInfoDisplay.render(config, AttackInfoDisplay.Perspective.ATTACKER)
				%AttackInfoDisplay2.render(config, AttackInfoDisplay.Perspective.DEFENDER)
				)
			button.mouse_exited.connect(func():
				%AttackInfos.hide())
		
		
		var line_target : Vector2 = %Camera3D.unproject_position(%Mech.get_weapon_position(i))
		selections.global_position = line_target
		var selector_origin : Vector2
		if i % 2 == 1:
			selections.global_position.x = %WeaponsLPosition.global_position.x
			selector_origin = selections.global_position + Vector2(selections.size.x, 0)
		else:
			selections.global_position.x = %WeaponsRPosition.global_position.x
			selector_origin = selections.global_position
		selector_origin.y += selections.size.y * 0.5
		
		var line := Line2D.new()
		%WeaponLines.add_child(line)
		line.points = [selector_origin, line_target]
		
		
			
	_update_lines()


func _on_close_button_pressed() -> void:
	ResourceSaver.save(%Mech.config, "user://mech_config.tres")
	get_tree().change_scene_to_file("res://game/main_menu/main_menu.tscn")
