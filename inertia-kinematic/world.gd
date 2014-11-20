
extends Node2D

const CREATE_TIME_DELAY = 0.5
const MAX_EXIST_TIME = 2.0

var is_can_create = true
var cursor = null
var exist_time = 0
var instances = []
var upper_dual = preload("res://upper_dual.scn.xml")


func _fixed_process(delta):
	var mouse_pos = Input.get_mouse_pos()
	cursor.set_pos(mouse_pos)
	if Input.is_action_pressed("point_and_click") and is_can_create:
			var u = upper_dual.instance()
			add_child(u)
			instances.append({"exist_time": 0, "instance": u})
			u.set_pos(mouse_pos)
			exist_time += delta
			is_can_create = false
	if exist_time > 0:
		exist_time += delta
		if exist_time > CREATE_TIME_DELAY:
			is_can_create = true
			exist_time = 0
	var for_deletion = []
	for i in range(instances.size() - 1, -1, -1):
		instances[i]["exist_time"] += delta
		if instances[i]["exist_time"] > MAX_EXIST_TIME:
			remove_and_delete_child(instances[i]["instance"])
			instances.remove(i)


func _ready():
	cursor = get_node("cursor")
	set_fixed_process(true)
