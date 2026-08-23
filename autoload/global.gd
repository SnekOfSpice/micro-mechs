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
