extends Command
class_name CommandDoAttack


var attacker : Mech
var target : Mech
var weapon_index : int


func execute() -> bool:
	await attacker.do_attack(target, weapon_index)
	return true
