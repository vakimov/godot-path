
extends KinematicBody2D

const GRAVITY = 500.0  # pixels/second

# Angle in degrees towards either side that the player can 
# consider "floor".
const FLOOR_ANGLE_TOLERANCE = 40
const WALK_FORCE = 600
const WALK_MAX_SPEED = 200
const FLOOR_STOP_FORCE = 1300
const AIR_STOP_FORCE = 0
const JUMP_SPEED = 200
const JUMP_MAX_AIRBORNE_TIME = 0.2

var velocity = Vector2()
var on_air_time = 100
var is_jumping = false

var is_prev_jump_pressed = false


var external_velocity = Vector2()
var external_velocities = {}
var is_external_velocity = false
var _key = 0

func append_external_velocity(velocity):
	_key += 1
	external_velocities[_key] = velocity
	is_external_velocity += 1
	add_external_velocity(velocity)
	return _key

func add_external_velocity(velocity):
	var n = external_velocity.normalized()
	external_velocity += n.slide(velocity)

func remove_external_velocity(index):
	is_external_velocity -= 1
	external_velocity = Vector2()
	external_velocities.erase(index)
	if is_external_velocity > 0:
		for key in external_velocities:
			var velocity = external_velocities[key]
			add_external_velocity(velocity)


var is_on_floor = false


func _fixed_process(delta):
	if Input.is_action_pressed("restart"):
		var global = get_node("/root/global")
		global.goto_scene("res://world.scn.xml")
	
	if is_external_velocity > 0:
		velocity = external_velocity
		var motion = velocity * delta  # integrate velocity into motion and move
		motion = move(motion)  # move and consume motion
		return
	
	var force = Vector2(0, GRAVITY)
	#var is_stopped = velocity.x != 0.0
	
	var is_going_to_walk_left = Input.is_action_pressed("move_left")
	var is_going_to_walk_right = Input.is_action_pressed("move_right")
	var is_going_to_jump = Input.is_action_pressed("jump")
	
	var is_going_to_stop = true
	
	if is_going_to_walk_left:
		if velocity.x > -WALK_MAX_SPEED:
			force.x -= WALK_FORCE
			is_going_to_stop = false
	elif is_going_to_walk_right:
		if velocity.x < WALK_MAX_SPEED:
			force.x += WALK_FORCE
			is_going_to_stop = false
	
	if is_going_to_stop:
		var vsign = sign(velocity.x)
		var vlen = abs(velocity.x)
		
		var stop_force
		if is_on_floor:
			stop_force = FLOOR_STOP_FORCE
		else:
			stop_force = AIR_STOP_FORCE
		vlen -= stop_force * delta
		if vlen < 0:
			vlen = 0
		
		velocity.x = vlen * vsign
	
	velocity += force * delta  # integrate forces to velocity
	
	var motion = velocity * delta  # integrate velocity into motion and move
	
	motion = move(motion)  # move and consume motion
	
	var floor_velocity = Vector2()
	
	is_on_floor = false
	
	if is_colliding():
		var n = get_collision_normal()
		
		if (rad2deg(acos(n.dot(Vector2(0,-1)))) < FLOOR_ANGLE_TOLERANCE):
			# if angle to the "up" vectors is < angle tolerance
			# char is on floor
			is_on_floor = true
			on_air_time = 0
			floor_velocity = get_collider_velocity()
		
		# But we were moving and our motion was interrupted, 
		# so try to complete the motion by "sliding"
		# by the normal
		motion = n.slide(motion)
		velocity = n.slide(velocity)
		
		move(motion)  # then move again

	if (floor_velocity != Vector2()):
		move(floor_velocity * delta)
	
	if is_jumping and velocity.y > 0:
		is_jumping = false
	
	if (is_going_to_jump and on_air_time < JUMP_MAX_AIRBORNE_TIME 
			and not is_prev_jump_pressed and not is_jumping):
		velocity.y = -JUMP_SPEED
		is_jumping = true
	
	on_air_time += delta
	is_prev_jump_pressed = is_going_to_jump


func _ready():
	set_meta("who", "player")
	set_fixed_process(true)
