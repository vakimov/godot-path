
extends RigidBody2D

# Angle in degrees towards either side that the player can 
# consider "floor".
const FLOOR_ANGLE_DOT_TOLERANCE = 0.6

var WALK_ACCEL = 1000.0
var WALK_DEACCEL = 500.0
var WALK_MAX_VELOCITY = 200.0

#var is_siding_left = false
var is_jumping = false
const JUMP_VELOCITY = 320
var is_stopping_jump = false
const STOP_JUMP_FORCE = 900.0

#const GRAVITY = 700.0
const AIR_ACCEL = 1000.0
const AIR_DEACCEL = 100.0

const MAX_FLOOR_AIRBORNE_TIME = 0.01
var airborne_time = 0

var floor_h_velocity = 0.0

func _integrate_forces(s):
	var lv = s.get_linear_velocity()
	var step = s.get_step()
	
	#var new_siding_left = is_siding_left
	
	var is_going_to_jump = Input.is_action_pressed("jump")
	var is_going_to_move_left = Input.is_action_pressed("move_left")
	var is_going_to_move_right = Input.is_action_pressed("move_right")
	
	# Deapply prev floor velocity
	lv.x -= floor_h_velocity
	floor_h_velocity = 0.0
	
	# Find the floor (a contact with upwards facing collision normal)
	var is_floor_found = false
	var floor_index = -1
	
	for x in range(s.get_contact_count()):
		var ci = s.get_contact_local_normal(x)
		var dot = ci.dot(Vector2(0,-1))
		if dot > FLOOR_ANGLE_DOT_TOLERANCE:
			is_floor_found = true
			floor_index = x
	
	if is_floor_found:
		airborne_time = 0.0
	else:
		airborne_time += step  # time it spent in the air
	
	var is_on_floor = airborne_time < MAX_FLOOR_AIRBORNE_TIME
	
	# Process jump
	if is_jumping:
		if lv.y > 0:
			# set off the is_jumping flag if going down
			is_jumping = false
		elif not is_going_to_jump:
			is_stopping_jump = true
		if is_stopping_jump:
			lv.y += STOP_JUMP_FORCE * step
	
	if is_on_floor:
		
		# Process logic when character is on floor
		if is_going_to_move_left and not is_going_to_move_right:
			if lv.x > -WALK_MAX_VELOCITY:
				lv.x -= WALK_ACCEL * step
		elif is_going_to_move_right and not is_going_to_move_left:
			if lv.x < WALK_MAX_VELOCITY:
				lv.x += WALK_ACCEL * step
		else:
			var xv = abs(lv.x)
			xv -= WALK_DEACCEL * step
			lv.x = sign(lv.x) * max(xv, 0)
		
		# Check jumping
		if not is_jumping and is_going_to_jump:
			lv.y = -JUMP_VELOCITY
			is_jumping = true
			is_stopping_jump = false
		
		# Check siding
		#if lv.x < 0 and is_going_to_move_left:
		#	new_siding_left = true
		#elif lv.x > - and is_going_to_move_right:
		#	new_siding_left = false
		
	else:
		
		# Process logic when the character is in the air
		if is_going_to_move_left and not is_going_to_move_right:
			if lv.x > -WALK_MAX_VELOCITY:
				lv.x -= AIR_ACCEL * step
		elif is_going_to_move_right and not is_going_to_move_left:
			if lv.x < WALK_MAX_VELOCITY:
				lv.x += AIR_ACCEL * step
		else:
			var xv = abs(lv.x)
			xv -= AIR_DEACCEL * step
			lv.x = sign(lv.x) * max(xv, 0)
	
	# Apply floor velocity
	if is_floor_found:
		floor_h_velocity = s.get_contact_collider_velocity_at_pos(floor_index).x
		lv.x += floor_h_velocity
	
	# Finally, apply gravity and set back the linear velocity
	lv += s.get_total_gravity() * step
	#lv += GRAVITY * Vector2(0,1) * step
	s.set_linear_velocity(lv)
	


func _ready():
	pass
