extends Action
class_name ActionWeapon


var config : WeaponConfig
var weapon_index : int


func do():
	Global.battle_stage.command_do_attack(owner, weapon_index)


func can_do() -> CanDoResult:
	if owner.is_overheated():
		return CanDoResult.OVERHEATED
	return owner.can_use_weapon(config)
