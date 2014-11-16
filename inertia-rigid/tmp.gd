
extends RigidBody2D

func _integrate_forces(s):
	var lv = s.get_linear_velocity()
	var step = s.get_step()
	
	for x in range(s.get_contact_count()):
		pass
	
	lv += s.get_total_gravity() * step
	s.set_linear_velocity(lv)


func _ready():
	pass
