extends Command
class_name CommandDoAttack


var attacker : Mech
var weapon_index : int


func execute() -> bool:
	for target : Mech in targets:
		await attacker.do_attack(target, weapon_index)
	
	return true
