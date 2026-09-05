extends Resource
class_name WeaponConfig


enum DamageType {
	Kinetic,
	Electric,
	Explosive,
}


@export var tech_id : String
@export var damage := Vector2i(0, 0)
@export var projectiles := 1
@export var inter_projectile_delay := 0.0
@export var weapon_range := Vector2i(1, 2)
@export var uses := -1:
	set(value):
		uses = value
		uses_left = uses
var uses_left := -1
@export var damage_type := DamageType.Kinetic
@export var energy_consumption_self := 0
@export var energy_consumption_target := 0
@export var heat_generation_self := 0
@export var heat_generation_target := 0
@export var bullet_consumption := 0
@export var rocket_consumption := 0
@export var knockback := 0
@export var knockback_self := 0
enum AttackPattern{
	## attacks all enemies in range
	ALL,
	## attacks the first enemy in range
	FRONT,
	## attacks the last enemy in range
	BACK
}
@export var attack_pattern := AttackPattern.FRONT

enum Kind{
	DEFAULT,
	STOMP,
}
var kind := Kind.DEFAULT
