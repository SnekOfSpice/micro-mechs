extends Action
class_name ActionWeapon


var config : WeaponConfig
var weapon_index : int


func do():
	Global.battle_stage.do_attack(owner, weapon_index)
