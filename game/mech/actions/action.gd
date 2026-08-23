@abstract
extends Resource
class_name Action

enum ActionType {
	MOVEMENT,
	WEAPON,
	COOL_DONW,
}

var action_type : ActionType
var owner : Mech


@abstract func do() -> void
	#owner.decrement_actions()
@abstract func can_do() -> bool
