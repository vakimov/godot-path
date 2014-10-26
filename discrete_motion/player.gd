
extends KinematicBody2D

const MOTION_SPEED = 160  # pixels/second
const STEP_SIZE = 16  # pixels

var steps_in_run = 1
var next_steps_in_run = steps_in_run
var _direction_takes = null
var _run_gone = 0

var label = null

# To detect when it should stops trying to move forward
var _motionless_count = 0
const MAX_MOTIONLESS_COUNT = 5

var _prev_pos = Vector2()
var _passed_segment = Vector2()
var velocity = Vector2()


func _fixed_process(delta):
	_passed_segment = get_pos() - _prev_pos
	velocity = _passed_segment / delta
	_prev_pos = get_pos()
	
	if _direction_takes == null:
		if (Input.is_action_pressed("move_up")):
			_direction_takes = Vector2( 0,-1)
		elif (Input.is_action_pressed("move_down")):
			_direction_takes = Vector2( 0, 1)
		elif (Input.is_action_pressed("move_left")):
			_direction_takes = Vector2(-1, 0)
		elif (Input.is_action_pressed("move_right")):
			_direction_takes = Vector2( 1, 0)
	
	if _direction_takes != null:
		if abs(velocity.length()) < 1:  # Is it kinda stoped?
			_motionless_count += 1
			if _motionless_count >= MAX_MOTIONLESS_COUNT:  # Belike it is.
				_end_motion()
				_move_to_perfect(get_pos())
		else:
			_motionless_count = 0
	if _direction_takes != null:
		_run_gone += _passed_segment.length()
		var length = delta * MOTION_SPEED
		var motion = _direction_takes
		if _run_gone + length > STEP_SIZE * steps_in_run:
			length = STEP_SIZE * steps_in_run - _run_gone
			_end_motion()
			_move_to_perfect(get_pos() + motion.normalized() * length)
		else:
			motion = motion.normalized() * length
			move(motion)


func _round_position(val):
	return round((val - (STEP_SIZE/2))/ STEP_SIZE) * STEP_SIZE + STEP_SIZE/2


# Move to perfectly centered position
func _move_to_perfect(pos):
	pos.x = _round_position(pos.x)
	pos.y = _round_position(pos.y)
	move_to(pos)


func _update_number():
	label.set_text(str(steps_in_run))


func _end_motion():
	_run_gone = 0
	_motionless_count = 0
	_direction_takes = null
	steps_in_run = next_steps_in_run
	_update_number()


func _ready():
	_prev_pos = get_pos()
	label = get_node("label")
	_update_number()
	set_fixed_process(true)
