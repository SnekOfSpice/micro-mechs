extends Resource
class_name CombatStats


var health : int:
	set(value):
		if value != health:
			health = value
			emit_changed()
var health_max : int:
	set(value):
		if value != health_max:
			health_max = value
			emit_changed()
var energy : int:
	set(value):
		if value != energy:
			energy = value
			emit_changed()
var energy_max : int:
	set(value):
		if value != energy_max:
			energy_max = value
			emit_changed()
var heat : int:
	set(value):
		if value != heat:
			heat = value
			emit_changed()
var heat_max : int:
	set(value):
		if value != heat_max:
			heat_max = value
			emit_changed()
var bullets : int:
	set(value):
		if value != bullets:
			bullets = value
			emit_changed()
var bullets_max : int:
	set(value):
		if value != bullets_max:
			bullets_max = value
			emit_changed()
var rockets : int:
	set(value):
		if value != rockets:
			rockets = value
			emit_changed()
var rockets_max : int:
	set(value):
		if value != rockets_max:
			rockets_max = value
			emit_changed()
