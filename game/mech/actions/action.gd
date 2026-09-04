@abstract
extends Resource
class_name Action

enum ActionType {
	MOVEMENT,
	WEAPON,
	COOL_DONW,
}

enum CanDoResult {
	CAN_DO,
	OVERHEATED,
	USED_THIS_TURN,
	OUT_OF_USES,
	OUT_OF_BULLETS,
	OUT_OF_ROCKETS,
	OUT_OF_ENERGY,
	OUT_OF_RANGE,
	MECH_IN_SPOT,
	EDGE_OF_ARENA,
	NO_COMBAT_STATS_ERR,
	OUT_OF_ACTIONS,
}


var action_type : ActionType
var owner : Mech


@abstract func do() -> void
	#owner.decrement_actions()
@abstract func can_do() -> CanDoResult
