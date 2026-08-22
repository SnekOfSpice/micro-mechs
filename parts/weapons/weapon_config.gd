extends Resource
class_name WeaponConfig


enum DamageType {
	Kinetic,
	Electric,
	Explosive,
}


@export var tech_id : String
@export var damage := Vector2(10, 20)
@export var weapon_range := Vector2(0, 1)
@export var uses := -1
@export var damage_type := DamageType.Kinetic
@export var energy_consumption_self := 0
@export var energy_consumption_target := 0
@export var heat_generatoion_self := 0
@export var heat_generatoion_target := 0
@export var bullet_consumption := 0
@export var rocket_consumption := 0
