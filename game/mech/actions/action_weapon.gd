extends Action
class_name ActionWeapon


var config : WeaponConfig
var weapon_index : int


func do():
	super()
	Global.battle_stage.do_attack(owner, weapon_index)


func can_do() -> bool:
	return owner.can_use_weapon(config)
