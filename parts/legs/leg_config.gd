extends Resource
class_name LegConfig



enum MovementType {
	WALK,
	TELEPORT
}


@export var health := 0
@export var movement := 1
@export var movement_type := MovementType.WALK
@export var stomp_damage := Vector2i(10, 10)
