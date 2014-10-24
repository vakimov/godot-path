
extends Area2D

const MOTION_SPEED = 150
const PATH = [
	[16 * 29, Vector2( 1, 0)],
	[16 * 26, Vector2( 0, 1)],
	[16 * 28, Vector2(-1, 0)],
	[16 * 23, Vector2( 0,-1)],
	
	[16 * 25, Vector2( 1, 0)],
	[16 * 20, Vector2( 0, 1)],
	[16 * 22, Vector2(-1, 0)],
	[16 * 17, Vector2( 0,-1)],
	
	[16 * 19, Vector2( 1, 0)],
	[16 * 14, Vector2( 0, 1)],
	[16 * 16, Vector2(-1, 0)],
	[16 * 11, Vector2( 0,-1)],
	
	[16 * 13, Vector2( 1, 0)],
	[16 *  8, Vector2( 0, 1)],
	[16 * 10, Vector2(-1, 0)],
	[16 *  5, Vector2( 0,-1)],
	
	[16 *  7, Vector2( 1, 0)],
	[16 *  2, Vector2( 0, 1)],
	[16 *  5, Vector2(-1, 0)],
]
var segment_n = 0
var segment_passed = 0
var segment_direction = null


func _move(segment_direction, length):
	var motion = segment_direction.normalized() * length
	set_pos(get_pos() + motion)
	


func _fixed_process(delta):
	
	var segment_direction = PATH[segment_n][1]
	var pos = get_pos()
	var length = MOTION_SPEED * delta
	if segment_passed + length >= PATH[segment_n][0]:
		var left = PATH[segment_n][0] - segment_passed
		_move(segment_direction, left)
		segment_n += 1
		if segment_n + 1 > PATH.size():
			set_fixed_process(false)
			return
		segment_direction = PATH[segment_n][1]
		_move(segment_direction, length - left)
		segment_passed = length - left
	_move(segment_direction, length)
	segment_passed += length


func _ready():
	pass
