extends Node


var player_mech : Mech
var npc_mech : Mech
var hud : PlayerHUD
var active_mech : Mech
var battle_stage : BattleStage


var player_config : MechConfig


func get_other_mech(mech : Mech) -> Mech:
	if player_mech == mech:
		return npc_mech
	return player_mech


func vec2_to_range_string(rangee : Vector2i) -> String:
	if rangee.x == rangee.y:
		return str(rangee.x)
	return "%s - %s" % [rangee.x, rangee.y]


func get_uses_string(current, maximum) -> String:
	var difference = maximum - current
	var uses_string := ""
	for i in current:
		uses_string += "[img]res://parts/weapons/use_on.png[/img]"
	for i in difference:
		uses_string += "[img]res://parts/weapons/use_off.png[/img]"
	return uses_string


func get_weapon_configs() -> Array:
	var result := []
	for file in DirAccess.get_files_at("res://parts/weapons/configs/"):
		result.append(file.trim_suffix(".tres"))
	return result
