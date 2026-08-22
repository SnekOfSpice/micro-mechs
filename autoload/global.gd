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
