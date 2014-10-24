
extends KinematicBody2D

# This is an demo showing
# how to run against the wall

const MOTION_SPEED = 160  # pixels/second

var enemy_activated = false


func _fixed_process(delta):
	
	var motion = Vector2()
	
	if Input.is_action_pressed("move_up"):
		motion += Vector2( 0, -1)
	if Input.is_action_pressed("move_bottom"):
		motion += Vector2( 0,  1)
	if Input.is_action_pressed("move_left"):
		motion += Vector2(-1,  0)
	if Input.is_action_pressed("move_right"):
		motion += Vector2( 1,  0)
		if !enemy_activated:
			get_node("/root/world/enemy").set_fixed_process(true)
			enemy_activated = true
	
	motion = motion.normalized() * MOTION_SPEED * delta
	move(motion)
	
	# run along the wall
	if is_colliding():
		var n = get_collision_normal()
		motion = n.slide(motion)
		move(motion)


func _ready():
	set_fixed_process(true)
